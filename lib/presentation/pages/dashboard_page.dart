import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/transaction_model.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../widgets/transaction_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _ds = TransactionLocalDataSource();

  bool _loading = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);

    try {
      final list = await _ds.getTransactions();
      setState(() => _transactions = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error cargando BD: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _balance {
    double total = 0;
    for (final tx in _transactions) {
      total += tx.isIncome ? tx.amount : -tx.amount;
    }
    return total;
  }

  Future<void> _goToAddTransaction() async {
    final result = await Navigator.pushNamed(context, '/add-transaction');

    // No dependemos del "result": recargamos desde BD para asegurar persistencia
    await _loadTransactions();
  }

  Future<void> _deleteTx(TransactionModel tx) async {
    if (tx.id == null) return;

    try {
      await _ds.deleteTransaction(tx.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transacción eliminada")),
        );
      }
      await _loadTransactions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error borrando: $e")),
        );
      }
    }
  }

  Future<void> _editTx(TransactionModel tx) async {
    final titleCtrl = TextEditingController(text: tx.title);
    final amountCtrl = TextEditingController(text: tx.amount.toStringAsFixed(2));
    TransactionType type = tx.type;

    final updated = await showDialog<TransactionModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar transacción"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Monto"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TransactionType>(
                value: type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text("Gasto"),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text("Ingreso"),
                  ),
                ],
                onChanged: (v) => type = v ?? type,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                final a = double.tryParse(amountCtrl.text.trim());

                if (t.isEmpty || a == null || a <= 0) return;

                Navigator.pop(
                  context,
                  TransactionModel(
                    id: tx.id,
                    title: t,
                    amount: a,
                    type: type,
                  ),
                );
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (updated == null) return;

    try {
      await _ds.updateTransaction(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transacción actualizada")),
        );
      }
      await _loadTransactions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error actualizando: $e")),
        );
      }
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
            const Text("Saldo Total", style: TextStyle(color: Colors.white70)),
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? const Center(child: Text("No hay transacciones aún"))
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            return TransactionItem(
                              tx: tx,
                              onEdit: () => _editTx(tx),
                              onDelete: () => _deleteTx(tx),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}