import 'package:json_annotation/json_annotation.dart';

part 'sheet_entry.g.dart';

enum SheetEntryCategory { food, transport, hotel, shopping, other }

@JsonSerializable()
class SheetEntry {
  final String id, name;
  final DateTime createdAt, updatedAt;
  final double amount;
  @JsonKey(defaultValue: SheetEntryCategory.other)
  final SheetEntryCategory category;

  SheetEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
    this.category = SheetEntryCategory.other,
  });

  factory SheetEntry.fromJson(Map<String, dynamic> json) =>
      _$SheetEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SheetEntryToJson(this);
}
