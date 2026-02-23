import 'package:flutter/material.dart';
import '../../data/transaction_model.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  TransactionType _type = TransactionType.expense;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.trim();
    final descText = _descController.text.trim();

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || descText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Revisá: monto válido y descripción.")),
      );
      return;
    }

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: descText,
      amount: amount,
      type: _type,
    );

    Navigator.pop(context, tx); // regresamos la transacción al Dashboard
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
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}