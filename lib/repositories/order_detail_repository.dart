import 'package:toriniku_geprek/models/menu_item.dart';
import 'package:toriniku_geprek/models/order_detail.dart';
import 'package:toriniku_geprek/services/database_service.dart';

class OrderDetailRepository {
  final DatabaseService _db;

  OrderDetailRepository({DatabaseService? db})
      : _db = db ?? DatabaseService.instance;

  Future<int> insert(OrderDetail detail) async {
    final database = await _db.database;
    return database.insert(DatabaseService.tableOrderDetails, detail.toMap());
  }

  /// Inserts multiple details in a single transaction.
  Future<void> insertAll(List<OrderDetail> details) async {
    final database = await _db.database;
    await database.transaction((txn) async {
      for (final detail in details) {
        await txn.insert(DatabaseService.tableOrderDetails, detail.toMap());
      }
    });
  }

  /// Returns all details for [orderId], joined with their menu item data.
  Future<List<OrderDetail>> getByOrderId(int orderId) async {
    final database = await _db.database;
    final maps = await database.rawQuery('''
      SELECT
        od.id           AS id,
        od.order_id     AS order_id,
        od.menu_item_id AS menu_item_id,
        od.unit_price   AS unit_price,
        od.quantity     AS quantity,
        od.subtotal     AS subtotal,
        m.name          AS item_name,
        m.description   AS item_description,
        m.category_id   AS item_category_id,
        m.price         AS item_price
      FROM ${DatabaseService.tableOrderDetails} od
      INNER JOIN ${DatabaseService.tableMenuItems} m ON m.id = od.menu_item_id
      WHERE od.order_id = ?
      ORDER BY od.id ASC
    ''', [orderId]);
    return maps.map(_fromJoinedMap).toList();
  }

  Future<OrderDetail?> getById(int id) async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableOrderDetails,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return OrderDetail.fromMap(maps.first);
  }

  Future<int> update(OrderDetail detail) async {
    assert(detail.id != null, 'Cannot update an order detail without an id');
    final database = await _db.database;
    return database.update(
      DatabaseService.tableOrderDetails,
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      DatabaseService.tableOrderDetails,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes every detail row belonging to [orderId].
  Future<int> deleteByOrderId(int orderId) async {
    final database = await _db.database;
    return database.delete(
      DatabaseService.tableOrderDetails,
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static OrderDetail _fromJoinedMap(Map<String, dynamic> map) {
    final menuItem = MenuItem(
      id: map['menu_item_id'] as int?,
      name: map['item_name'] as String,
      description: map['item_description'] as String?,
      categoryId: map['item_category_id'] as int,
      price: (map['item_price'] as num).toDouble(),
    );
    return OrderDetail.fromMap(map, menuItem: menuItem);
  }
}
