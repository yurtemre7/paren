import 'package:json_annotation/json_annotation.dart';
import 'package:paren/classes/sheet_entry.dart';

part 'sheet.g.dart';

@JsonSerializable()
class Sheet {
  final String id, name, fromCurrency, toCurrency;
  final DateTime createdAt, updatedAt;
  final List<SheetEntry> entries;

  Sheet({
    required this.id,
    required this.name,
    required this.fromCurrency,
    required this.toCurrency,
    required this.createdAt,
    required this.updatedAt,
    required this.entries,
  });

  factory Sheet.fromJson(Map<String, dynamic> json) => _$SheetFromJson(json);

  Map<String, dynamic> toJson() => _$SheetToJson(this);
}
