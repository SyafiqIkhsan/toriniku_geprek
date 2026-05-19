import 'package:toriniku_geprek/models/category.dart';
import 'package:toriniku_geprek/models/menu_item.dart';
import 'package:toriniku_geprek/services/database_service.dart';

class MenuRepository {
  final DatabaseService _db;

  MenuRepository({DatabaseService? db}) : _db = db ?? DatabaseService.instance;

  Future<int> insert(MenuItem item) async {
    final database = await _db.database;
    return database.insert(DatabaseService.tableMenuItems, item.toMap());
  }

  /// Returns all menu items joined with their category.
  Future<List<MenuItem>> getAll() async {
    final database = await _db.database;
    final maps = await database.rawQuery('''
      SELECT
        m.id          AS id,
        m.name        AS name,
        m.description AS description,
        m.category_id AS category_id,
        m.price       AS price,
        c.id          AS cat_id,
        c.name        AS cat_name
      FROM ${DatabaseService.tableMenuItems} m
      INNER JOIN ${DatabaseService.tableCategories} c ON c.id = m.category_id
      ORDER BY c.name ASC, m.name ASC
    ''');
    return maps.map(_fromJoinedMap).toList();
  }

  /// Returns all menu items for a given [categoryId].
  Future<List<MenuItem>> getByCategory(int categoryId) async {
    final database = await _db.database;
    final maps = await database.rawQuery('''
      SELECT
        m.id          AS id,
        m.name        AS name,
        m.description AS description,
        m.category_id AS category_id,
        m.price       AS price,
        c.id          AS cat_id,
        c.name        AS cat_name
      FROM ${DatabaseService.tableMenuItems} m
      INNER JOIN ${DatabaseService.tableCategories} c ON c.id = m.category_id
      WHERE m.category_id = ?
      ORDER BY m.name ASC
    ''', [categoryId]);
    return maps.map(_fromJoinedMap).toList();
  }

  Future<MenuItem?> getById(int id) async {
    final database = await _db.database;
    final maps = await database.rawQuery('''
      SELECT
        m.id          AS id,
        m.name        AS name,
        m.description AS description,
        m.category_id AS category_id,
        m.price       AS price,
        c.id          AS cat_id,
        c.name        AS cat_name
      FROM ${DatabaseService.tableMenuItems} m
      INNER JOIN ${DatabaseService.tableCategories} c ON c.id = m.category_id
      WHERE m.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return _fromJoinedMap(maps.first);
  }

  Future<int> update(MenuItem item) async {
    assert(item.id != null, 'Cannot update a menu item without an id');
    final database = await _db.database;
    return database.update(
      DatabaseService.tableMenuItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      DatabaseService.tableMenuItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static MenuItem _fromJoinedMap(Map<String, dynamic> map) {
    final category = Category(
      id: map['cat_id'] as int?,
      name: map['cat_name'] as String,
    );
    return MenuItem.fromMap(map, category: category);
  }
}
