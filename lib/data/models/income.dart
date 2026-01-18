import 'package:isar/isar.dart';

part 'income.g.dart';

enum IncomeType {
  cash, // 0
  upi, // 1
  bankTransfer, // 2
  other, // 3
}

@collection
class Income {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  IncomeType type = IncomeType.cash;

  String? note; // Optional description

  DateTime createdAt = DateTime.now();

  DateTime incomeDate = DateTime.now();

  // Helper to get type label
  String get typeLabel {
    switch (type) {
      case IncomeType.cash:
        return 'Cash';
      case IncomeType.upi:
        return 'UPI';
      case IncomeType.bankTransfer:
        return 'Bank Transfer';
      case IncomeType.other:
        return 'Other';
    }
  }

  // Copy with method
  Income copyWith({
    Id? id,
    double? amount,
    IncomeType? type,
    String? note,
    DateTime? createdAt,
    DateTime? incomeDate,
  }) {
    return Income()
      ..id = id ?? this.id
      ..amount = amount ?? this.amount
      ..type = type ?? this.type
      ..note = note ?? this.note
      ..createdAt = createdAt ?? this.createdAt
      ..incomeDate = incomeDate ?? this.incomeDate;
  }
}
