import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../data/transaction_model.dart';

class TransactionLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertTransaction(TransactionModel tx) async {
    try {
      final db = await _dbHelper.database;

      final map = tx.toMap()..remove('id');

      return await db.insert(
        DatabaseHelper.tableTransactions,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Error insertando transacción: $e");
    }
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.query(
        DatabaseHelper.tableTransactions,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );

      return result.map((row) => TransactionModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception("Error leyendo transacciones: $e");
    }
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    try {
      final db = await _dbHelper.database;

      if (tx.id == null) throw Exception("No se puede actualizar: id es null");

      return await db.update(
        DatabaseHelper.tableTransactions,
        tx.toMap()..remove('id'),
        where: 'id = ? AND user_id = ?',
        whereArgs: [tx.id, tx.userId],
      );
    } catch (e) {
      throw Exception("Error actualizando transacción: $e");
    }
  }

  Future<int> deleteTransaction(int id, String userId) async {
    try {
      final db = await _dbHelper.database;

      return await db.delete(
        DatabaseHelper.tableTransactions,
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
    } catch (e) {
      throw Exception("Error borrando transacción: $e");
    }
  }
}