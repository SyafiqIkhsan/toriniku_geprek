enum OrderStatus { pending, completed, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class Order {
  final int? id;
  final String? notes;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    this.id,
    this.notes,
    required this.totalPrice,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  Order copyWith({
    int? id,
    String? notes,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'notes': notes,
      'total_price': totalPrice,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      notes: map['notes'] as String?,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: OrderStatusExtension.fromString(map['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'Order(id: $id, totalPrice: $totalPrice, status: ${status.value}, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
