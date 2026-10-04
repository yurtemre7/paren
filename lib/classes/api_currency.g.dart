// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiCurrency _$ApiCurrencyFromJson(Map<String, dynamic> json) => ApiCurrency(
  isoCode: json['iso_code'] as String,
  name: json['name'] as String,
  isoNumeric: json['iso_numeric'] as String?,
  symbol: json['symbol'] as String?,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
);

Map<String, dynamic> _$ApiCurrencyToJson(ApiCurrency instance) =>
    <String, dynamic>{
      'iso_code': instance.isoCode,
      'iso_numeric': instance.isoNumeric,
      'name': instance.name,
      'symbol': instance.symbol,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
    };
