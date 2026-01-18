import 'package:isar/isar.dart';

part 'subscription_category.g.dart';

@collection
class SubscriptionCategory {
  Id id = Isar.autoIncrement;

  late String name; // "Passport", "Netflix", "Birthday"

  String? iconName; // Material icon name for display

  int colorValue = 0xFF6750A4; // Category color as int

  bool isDocument = false; // true = Document folder, false = Reminder folder

  // Create a copy with optional modifications
  SubscriptionCategory copyWith({
    Id? id,
    String? name,
    String? iconName,
    int? colorValue,
    bool? isDocument,
  }) {
    return SubscriptionCategory()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..iconName = iconName ?? this.iconName
      ..colorValue = colorValue ?? this.colorValue
      ..isDocument = isDocument ?? this.isDocument;
  }
}
