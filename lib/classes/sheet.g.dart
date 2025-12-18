// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sheet _$SheetFromJson(Map<String, dynamic> json) => Sheet(
  id: json['id'] as String,
  name: json['name'] as String,
  fromCurrency: json['fromCurrency'] as String,
  toCurrency: json['toCurrency'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  entries: (json['entries'] as List<dynamic>)
      .map((e) => SheetEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SheetToJson(Sheet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'fromCurrency': instance.fromCurrency,
  'toCurrency': instance.toCurrency,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'entries': instance.entries,
};
