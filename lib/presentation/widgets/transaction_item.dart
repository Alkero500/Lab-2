import 'package:flutter/material.dart';
import '../../data/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;

    return Card(
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.trending_up : Icons.trending_down,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(tx.title),
        subtitle: Text(
          "${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}",
        ),
        trailing: Text(
          (isIncome ? "+ " : "- ") + tx.amount.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}