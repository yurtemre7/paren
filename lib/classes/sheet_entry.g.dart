// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetEntry _$SheetEntryFromJson(Map<String, dynamic> json) => SheetEntry(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  amount: (json['amount'] as num).toDouble(),
  category:
      $enumDecodeNullable(_$SheetEntryCategoryEnumMap, json['category']) ??
      SheetEntryCategory.other,
);

Map<String, dynamic> _$SheetEntryToJson(SheetEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'amount': instance.amount,
      'category': _$SheetEntryCategoryEnumMap[instance.category]!,
    };

const _$SheetEntryCategoryEnumMap = {
  SheetEntryCategory.food: 'food',
  SheetEntryCategory.transport: 'transport',
  SheetEntryCategory.hotel: 'hotel',
  SheetEntryCategory.shopping: 'shopping',
  SheetEntryCategory.other: 'other',
};
