import 'package:isar/isar.dart';

part 'expense_category.g.dart';

/// The three main expense types
enum ExpenseType {
  needs, // Essential expenses (groceries, rent, utilities)
  wants, // Non-essential but desired (entertainment, dining out)
  savings, // Investments, savings, emergency fund
}

@collection
class ExpenseCategory {
  Id id = Isar.autoIncrement;

  late String
  name; // User-defined category name (e.g., "Eating Out", "Groceries")

  @enumerated
  ExpenseType type = ExpenseType.needs; // Parent type (Needs/Wants/Savings)

  int colorValue = 0xFF6200EE; // Category color

  String? iconName; // Optional icon identifier

  DateTime createdAt = DateTime.now();

  bool isActive = true;

  // Helper to get color
  int get color => colorValue;

  // Helper to get type label
  String get typeLabel {
    switch (type) {
      case ExpenseType.needs:
        return 'Needs';
      case ExpenseType.wants:
        return 'Wants';
      case ExpenseType.savings:
        return 'Savings';
    }
  }

  // Copy with method
  ExpenseCategory copyWith({
    Id? id,
    String? name,
    ExpenseType? type,
    int? colorValue,
    String? iconName,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ExpenseCategory()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..type = type ?? this.type
      ..colorValue = colorValue ?? this.colorValue
      ..iconName = iconName ?? this.iconName
      ..createdAt = createdAt ?? this.createdAt
      ..isActive = isActive ?? this.isActive;
  }
}
