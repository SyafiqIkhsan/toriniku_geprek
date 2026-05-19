import 'package:toriniku_geprek/models/category.dart';

class MenuItem {
  final int? id;
  final String name;
  final String? description;
  final int categoryId;
  final double price;

  /// Populated when fetched with a JOIN — not stored in the DB.
  final Category? category;

  const MenuItem({
    this.id,
    required this.name,
    this.description,
    required this.categoryId,
    required this.price,
    this.category,
  });

  MenuItem copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    double? price,
    Category? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, {Category? category}) {
    return MenuItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      categoryId: map['category_id'] as int,
      price: (map['price'] as num).toDouble(),
      category: category,
    );
  }

  @override
  String toString() =>
      'MenuItem(id: $id, name: $name, price: $price, categoryId: $categoryId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
