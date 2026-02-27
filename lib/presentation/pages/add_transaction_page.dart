import 'package:flutter/material.dart';
import '../../data/transaction_model.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _ds = TransactionLocalDataSource();

  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    final descText = _descController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || descText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Revisá: monto válido y descripción.")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final tx = TransactionModel(
        title: descText,
        amount: amount,
        type: _type,
      );

      await _ds.insertTransaction(tx);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transacción guardada")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error guardando: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto",
                hintText: "Ej: 250.00",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                hintText: "Ej: Netflix / Súper / Salario",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TransactionType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: "Tipo",
                border: OutlineInputBorder(),
              ),
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
              onChanged: (value) {
                if (value == null) return;
                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? "Guardando..." : "Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}