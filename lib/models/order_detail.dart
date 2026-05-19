import 'package:toriniku_geprek/models/menu_item.dart';

class OrderDetail {
  final int? id;
  final int menuItemId;
  final int orderId;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  /// Populated when fetched with a JOIN — not stored in the DB.
  final MenuItem? menuItem;

  const OrderDetail({
    this.id,
    required this.menuItemId,
    required this.orderId,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.menuItem,
  });

  /// Convenience constructor that auto-computes subtotal.
  factory OrderDetail.create({
    int? id,
    required int menuItemId,
    required int orderId,
    required double unitPrice,
    required int quantity,
    MenuItem? menuItem,
  }) {
    return OrderDetail(
      id: id,
      menuItemId: menuItemId,
      orderId: orderId,
      unitPrice: unitPrice,
      quantity: quantity,
      subtotal: unitPrice * quantity,
      menuItem: menuItem,
    );
  }

  OrderDetail copyWith({
    int? id,
    int? menuItemId,
    int? orderId,
    double? unitPrice,
    int? quantity,
    double? subtotal,
    MenuItem? menuItem,
  }) {
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newQuantity = quantity ?? this.quantity;
    return OrderDetail(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      orderId: orderId ?? this.orderId,
      unitPrice: newUnitPrice,
      quantity: newQuantity,
      // Recalculate subtotal if price or quantity changed.
      subtotal: (unitPrice != null || quantity != null)
          ? newUnitPrice * newQuantity
          : subtotal ?? this.subtotal,
      menuItem: menuItem ?? this.menuItem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'menu_item_id': menuItemId,
      'order_id': orderId,
      'unit_price': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map, {MenuItem? menuItem}) {
    return OrderDetail(
      id: map['id'] as int?,
      menuItemId: map['menu_item_id'] as int,
      orderId: map['order_id'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      menuItem: menuItem,
    );
  }

  @override
  String toString() =>
      'OrderDetail(id: $id, menuItemId: $menuItemId, quantity: $quantity, subtotal: $subtotal)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
