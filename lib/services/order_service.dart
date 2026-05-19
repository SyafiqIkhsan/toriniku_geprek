import 'package:toriniku_geprek/models/order.dart';
import 'package:toriniku_geprek/models/order_detail.dart';
import 'package:toriniku_geprek/repositories/order_detail_repository.dart';
import 'package:toriniku_geprek/repositories/order_repository.dart';

/// Represents a menu item selected during order creation.
class CartItem {
  final int menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}

class OrderService {
  final OrderRepository _orderRepo;
  final OrderDetailRepository _detailRepo;

  OrderService({
    OrderRepository? orderRepository,
    OrderDetailRepository? orderDetailRepository,
  })  : _orderRepo = orderRepository ?? OrderRepository(),
        _detailRepo = orderDetailRepository ?? OrderDetailRepository();

  // ─── Queries ──────────────────────────────────────────────────────────────

  Future<List<Order>> getAllOrders() => _orderRepo.getAll();

  Future<List<Order>> getOrdersByStatus(OrderStatus status) =>
      _orderRepo.getByStatus(status);

  Future<Order?> getOrderById(int id) => _orderRepo.getById(id);

  Future<List<OrderDetail>> getOrderDetails(int orderId) =>
      _detailRepo.getByOrderId(orderId);

  // ─── Commands ─────────────────────────────────────────────────────────────

  /// Creates a new [Order] from [cartItems] in a single logical operation.
  ///
  /// Returns the persisted [Order] with its generated id.
  Future<Order> createOrder({
    required List<CartItem> cartItems,
    String? notes,
  }) async {
    if (cartItems.isEmpty) {
      throw ArgumentError('Cannot create an order with no items.');
    }

    final double total =
        cartItems.fold(0, (sum, item) => sum + item.subtotal);

    final order = Order(
      notes: notes?.trim(),
      totalPrice: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    final orderId = await _orderRepo.insert(order);

    final details = cartItems
        .map(
          (item) => OrderDetail.create(
            menuItemId: item.menuItemId,
            orderId: orderId,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
          ),
        )
        .toList();

    await _detailRepo.insertAll(details);

    return order.copyWith(id: orderId);
  }

  /// Updates the status of an order (e.g. mark as completed or cancelled).
  Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    final order = await _orderRepo.getById(orderId);
    if (order == null) {
      throw StateError('Order #$orderId not found.');
    }
    await _orderRepo.update(order.copyWith(status: status));
  }

  /// Replaces all items in an existing pending order.
  ///
  /// Recalculates and persists the new total price.
  Future<Order> updateOrderItems({
    required int orderId,
    required List<CartItem> cartItems,
    String? notes,
  }) async {
    final order = await _orderRepo.getById(orderId);
    if (order == null) {
      throw StateError('Order #$orderId not found.');
    }
    if (order.status != OrderStatus.pending) {
      throw StateError('Only pending orders can be modified.');
    }
    if (cartItems.isEmpty) {
      throw ArgumentError('Cannot update an order to have no items.');
    }

    final double total =
        cartItems.fold(0, (sum, item) => sum + item.subtotal);

    // Replace details (CASCADE delete + re-insert).
    await _detailRepo.deleteByOrderId(orderId);

    final details = cartItems
        .map(
          (item) => OrderDetail.create(
            menuItemId: item.menuItemId,
            orderId: orderId,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
          ),
        )
        .toList();

    await _detailRepo.insertAll(details);
    await _orderRepo.updateTotal(orderId, total);

    return order.copyWith(
      notes: notes?.trim() ?? order.notes,
      totalPrice: total,
    );
  }

  /// Cancels an order (soft delete via status).
  Future<void> cancelOrder(int orderId) =>
      updateOrderStatus(orderId, OrderStatus.cancelled);

  /// Completes an order.
  Future<void> completeOrder(int orderId) =>
      updateOrderStatus(orderId, OrderStatus.completed);
}
