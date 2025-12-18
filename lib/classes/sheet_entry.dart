import 'package:json_annotation/json_annotation.dart';

part 'sheet_entry.g.dart';

@JsonSerializable()
class SheetEntry {
  final String id, name;
  final DateTime createdAt, updatedAt;
  final double amount;

  SheetEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
  });

  factory SheetEntry.fromJson(Map<String, dynamic> json) =>
      _$SheetEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SheetEntryToJson(this);
}
