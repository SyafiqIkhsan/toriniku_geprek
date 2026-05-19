import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton that owns the SQLite [Database] connection and schema.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;

  static const int _version = 1;
  static const String _dbName = 'toriniku_geprek.db';

  // ─── Table names ──────────────────────────────────────────────────────────
  static const String tableCategories = 'categories';
  static const String tableMenuItems = 'menu_items';
  static const String tableOrders = 'orders';
  static const String tableOrderDetails = 'order_details';

  // ─── Public accessor ──────────────────────────────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ─── Initialisation ───────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign-key enforcement.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT    NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMenuItems (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        price       REAL    NOT NULL CHECK(price >= 0),
        FOREIGN KEY (category_id)
          REFERENCES $tableCategories(id)
          ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrders (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        notes       TEXT,
        total_price REAL    NOT NULL DEFAULT 0 CHECK(total_price >= 0),
        status      TEXT    NOT NULL DEFAULT 'pending'
                              CHECK(status IN ('pending','completed','cancelled')),
        created_at  TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderDetails (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id     INTEGER NOT NULL,
        menu_item_id INTEGER NOT NULL,
        unit_price   REAL    NOT NULL CHECK(unit_price >= 0),
        quantity     INTEGER NOT NULL CHECK(quantity > 0),
        subtotal     REAL    NOT NULL CHECK(subtotal >= 0),
        FOREIGN KEY (order_id)
          REFERENCES $tableOrders(id)
          ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id)
          REFERENCES $tableMenuItems(id)
          ON DELETE RESTRICT
      )
    ''');

    await _seedData(db);
  }

  /// Seed some default categories so the app is usable immediately.
  Future<void> _seedData(Database db) async {
    const defaultCategories = ['Ayam', 'Minuman', 'Pelengkap', 'Dessert'];
    for (final name in defaultCategories) {
      await db.insert(tableCategories, {'name': name});
    }
  }

  /// Close the database (useful for testing).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
