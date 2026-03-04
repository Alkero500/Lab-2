import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'finanzatrack.db';
  static const _dbVersion = 3;

  static const tableTransactions = 'transactions';
  static const tableSettings = 'app_settings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, _dbName);

      return await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableTransactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              type TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE $tableSettings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE INDEX idx_transactions_user_id_id
            ON $tableTransactions (user_id, id)
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Si vienes de v1 -> v2, crea settings
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE $tableSettings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
              )
            ''');
          }

          // Si vienes de v2 -> v3, agrega user_id a transactions
          if (oldVersion < 3) {
            await db.execute('''
              ALTER TABLE $tableTransactions
              ADD COLUMN user_id TEXT NOT NULL DEFAULT ''
            ''');

            await db.execute('''
              CREATE INDEX IF NOT EXISTS idx_transactions_user_id_id
              ON $tableTransactions (user_id, id)
            ''');
          }
        },
      );
    } catch (e) {
      throw Exception("Error abriendo la base de datos: $e");
    }
  }
}