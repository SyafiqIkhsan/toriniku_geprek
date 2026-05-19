import 'package:toriniku_geprek/models/order.dart';
import 'package:toriniku_geprek/services/database_service.dart';

class OrderRepository {
  final DatabaseService _db;

  OrderRepository({DatabaseService? db}) : _db = db ?? DatabaseService.instance;

  Future<int> insert(Order order) async {
    final database = await _db.database;
    return database.insert(DatabaseService.tableOrders, order.toMap());
  }

  Future<List<Order>> getAll() async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableOrders,
      orderBy: 'created_at DESC',
    );
    return maps.map(Order.fromMap).toList();
  }

  Future<Order?> getById(int id) async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableOrders,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Order.fromMap(maps.first);
  }

  Future<List<Order>> getByStatus(OrderStatus status) async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableOrders,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
    return maps.map(Order.fromMap).toList();
  }

  Future<int> update(Order order) async {
    assert(order.id != null, 'Cannot update an order without an id');
    final database = await _db.database;
    return database.update(
      DatabaseService.tableOrders,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  /// Updates only the total_price column (useful after detail changes).
  Future<int> updateTotal(int orderId, double totalPrice) async {
    final database = await _db.database;
    return database.update(
      DatabaseService.tableOrders,
      {'total_price': totalPrice},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      DatabaseService.tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
