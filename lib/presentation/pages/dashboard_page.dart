import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/transaction_model.dart';
import '../widgets/transaction_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: "1",
      title: "Salario",
      amount: 1500,
      type: TransactionType.income,
    ),
    TransactionModel(
      id: "2",
      title: "Netflix",
      amount: 12.99,
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: "3",
      title: "Super",
      amount: 60.50,
      type: TransactionType.expense,
    ),
  ];

  double get _balance {
    double total = 0;
    for (final tx in _transactions) {
      total += tx.isIncome ? tx.amount : -tx.amount;
    }
    return total;
  }

  Future<void> _goToAddTransaction() async {
    final result = await Navigator.pushNamed(context, '/add-transaction');

    if (result is TransactionModel) {
      setState(() {
        _transactions.insert(0, result);
      });
    }
  }

  Widget _balanceCard() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saldo Total",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              "\$ ${_balance.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Gasto semanal"),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final heights = [20, 45, 30, 55, 25, 40, 35];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: heights[i].toDouble(),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FinanzaTrack")),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _balanceCard(),
            const SizedBox(height: 12),
            _miniChart(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  return TransactionItem(tx: _transactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}