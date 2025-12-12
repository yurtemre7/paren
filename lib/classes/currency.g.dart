// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Currency _$CurrencyFromJson(Map<String, dynamic> json) => Currency(
  id: json['id'] as String,
  name: json['name'] as String,
  symbol: json['symbol'] as String,
  rate: (json['rate'] as num).toDouble(),
);

Map<String, dynamic> _$CurrencyToJson(Currency instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'symbol': instance.symbol,
  'rate': instance.rate,
};
