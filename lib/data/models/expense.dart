import 'package:isar/isar.dart';

part 'expense.g.dart';

enum PaymentMethod {
  cash, // 0
  upi, // 1
}

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late double amount; // Amount spent

  int? categoryId; // Link to ExpenseCategory

  int? taskId; // Link to Task (optional - expense can be linked to a task)

  String? note; // Optional description

  @enumerated
  PaymentMethod paymentMethod = PaymentMethod.cash; // Default to cash

  DateTime createdAt = DateTime.now();

  DateTime expenseDate = DateTime.now(); // When the expense occurred

  // Helper to get payment method label
  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
    }
  }

  // Copy with method
  Expense copyWith({
    Id? id,
    double? amount,
    int? categoryId,
    int? taskId,
    String? note,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? expenseDate,
  }) {
    return Expense()
      ..id = id ?? this.id
      ..amount = amount ?? this.amount
      ..categoryId = categoryId ?? this.categoryId
      ..taskId = taskId ?? this.taskId
      ..note = note ?? this.note
      ..paymentMethod = paymentMethod ?? this.paymentMethod
      ..createdAt = createdAt ?? this.createdAt
      ..expenseDate = expenseDate ?? this.expenseDate;
  }
}
