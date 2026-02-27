import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../data/transaction_model.dart';

class TransactionLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertTransaction(TransactionModel tx) async {
    try {
      final db = await _dbHelper.database;

      // No mandamos id porque es AUTOINCREMENT
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

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final db = await _dbHelper.database;

      // REQUERIMIENTO: orderBy id DESC
      final result = await db.query(
        DatabaseHelper.tableTransactions,
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

      if (tx.id == null) {
        throw Exception("No se puede actualizar: id es null");
      }

      return await db.update(
        DatabaseHelper.tableTransactions,
        tx.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [tx.id],
      );
    } catch (e) {
      throw Exception("Error actualizando transacción: $e");
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _dbHelper.database;

      return await db.delete(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error borrando transacción: $e");
    }
  }
}