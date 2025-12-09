import 'package:isar/isar.dart';

part 'subscription_category.g.dart';

@collection
class SubscriptionCategory {
  Id id = Isar.autoIncrement;

  late String name; // "OTT", "Documents", "Travel"

  String? iconName; // Material icon name for display

  int colorValue = 0xFF6750A4; // Category color as int

  // Create a copy with optional modifications
  SubscriptionCategory copyWith({
    Id? id,
    String? name,
    String? iconName,
    int? colorValue,
  }) {
    return SubscriptionCategory()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..iconName = iconName ?? this.iconName
      ..colorValue = colorValue ?? this.colorValue;
  }
}
