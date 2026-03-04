enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type.name,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final typeString = (map['type'] ?? 'expense') as String;
    final parsedType = TransactionType.values.firstWhere(
      (t) => t.name == typeString,
      orElse: () => TransactionType.expense,
    );

    return TransactionModel(
      id: map['id'] as int?,
      userId: (map['user_id'] ?? '') as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: parsedType,
    );
  }

  bool get isIncome => type == TransactionType.income;
}