import 'package:toriniku_geprek/models/category.dart';
import 'package:toriniku_geprek/services/database_service.dart';

class CategoryRepository {
  final DatabaseService _db;

  CategoryRepository({DatabaseService? db})
      : _db = db ?? DatabaseService.instance;

  Future<int> insert(Category category) async {
    final database = await _db.database;
    return database.insert(DatabaseService.tableCategories, category.toMap());
  }

  Future<List<Category>> getAll() async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableCategories,
      orderBy: 'name ASC',
    );
    return maps.map(Category.fromMap).toList();
  }

  Future<Category?> getById(int id) async {
    final database = await _db.database;
    final maps = await database.query(
      DatabaseService.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> update(Category category) async {
    assert(category.id != null, 'Cannot update a category without an id');
    final database = await _db.database;
    return database.update(
      DatabaseService.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await _db.database;
    return database.delete(
      DatabaseService.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
