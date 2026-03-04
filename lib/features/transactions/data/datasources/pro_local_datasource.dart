import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';

class ProLocalDataSource {
  final _dbHelper = DatabaseHelper.instance;

  String _keyFor(String uid) => 'is_pro_$uid';

  Future<bool> isPro(String uid) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      DatabaseHelper.tableSettings,
      where: 'key = ?',
      whereArgs: [_keyFor(uid)],
      limit: 1,
    );

    if (result.isEmpty) return false;
    return result.first['value'] == '1';
  }

  Future<void> setPro(String uid, bool value) async {
    final db = await _dbHelper.database;

    await db.insert(
      DatabaseHelper.tableSettings,
      {'key': _keyFor(uid), 'value': value ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}