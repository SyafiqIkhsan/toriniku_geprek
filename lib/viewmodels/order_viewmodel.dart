import 'package:flutter/foundation.dart';
import 'package:toriniku_geprek/models/order.dart';
import 'package:toriniku_geprek/models/order_detail.dart';
import 'package:toriniku_geprek/services/order_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _service;

  OrderViewModel({OrderService? service})
      : _service = service ?? OrderService();

  // ─── State ────────────────────────────────────────────────────────────────
  List<Order> _orders = [];
  Order? _activeOrder;
  List<OrderDetail> _activeOrderDetails = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// In-memory cart accumulates items before creating a real DB order.
  final List<CartItem> _cart = [];

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<Order> get orders => List.unmodifiable(_orders);
  Order? get activeOrder => _activeOrder;
  List<OrderDetail> get activeOrderDetails =>
      List.unmodifiable(_activeOrderDetails);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  List<CartItem> get cart => List.unmodifiable(_cart);
  double get cartTotal =>
      _cart.fold(0, (sum, item) => sum + item.subtotal);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => _cart.isEmpty;

  // ─── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      _orders = await _service.getAllOrders();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrderDetails(int orderId) async {
    _setLoading(true);
    try {
      _activeOrder = await _service.getOrderById(orderId);
      _activeOrderDetails = await _service.getOrderDetails(orderId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load order details: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Cart management ──────────────────────────────────────────────────────

  void addToCart({
    required int menuItemId,
    required String name,
    required double unitPrice,
    int quantity = 1,
  }) {
    final index = _cart.indexWhere((i) => i.menuItemId == menuItemId);
    if (index >= 0) {
      final existing = _cart[index];
      _cart[index] = CartItem(
        menuItemId: menuItemId,
        name: name,
        unitPrice: unitPrice,
        quantity: existing.quantity + quantity,
      );
    } else {
      _cart.add(CartItem(
        menuItemId: menuItemId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(int menuItemId) {
    _cart.removeWhere((i) => i.menuItemId == menuItemId);
    notifyListeners();
  }

  void updateCartItemQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(menuItemId);
      return;
    }
    final index = _cart.indexWhere((i) => i.menuItemId == menuItemId);
    if (index >= 0) {
      final item = _cart[index];
      _cart[index] = CartItem(
        menuItemId: item.menuItemId,
        name: item.name,
        unitPrice: item.unitPrice,
        quantity: quantity,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ─── Order creation ───────────────────────────────────────────────────────

  /// Persists the current cart as a new order.
  Future<Order?> placeOrder({String? notes}) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Cart is empty.';
      notifyListeners();
      return null;
    }
    _setLoading(true);
    try {
      final order = await _service.createOrder(
        cartItems: List.from(_cart),
        notes: notes,
      );
      _orders = [order, ..._orders];
      _cart.clear();
      _errorMessage = null;
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Status management ────────────────────────────────────────────────────

  Future<bool> completeOrder(int orderId) =>
      _updateStatus(orderId, OrderStatus.completed);

  Future<bool> cancelOrder(int orderId) =>
      _updateStatus(orderId, OrderStatus.cancelled);

  Future<bool> _updateStatus(int orderId, OrderStatus status) async {
    _setLoading(true);
    try {
      if (status == OrderStatus.completed) {
        await _service.completeOrder(orderId);
      } else {
        await _service.cancelOrder(orderId);
      }
      _orders = _orders
          .map((o) => o.id == orderId ? o.copyWith(status: status) : o)
          .toList();
      if (_activeOrder?.id == orderId) {
        _activeOrder = _activeOrder!.copyWith(status: status);
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
