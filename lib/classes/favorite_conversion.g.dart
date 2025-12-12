// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_conversion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteConversion _$FavoriteConversionFromJson(Map<String, dynamic> json) =>
    FavoriteConversion(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$FavoriteConversionToJson(FavoriteConversion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromCurrency': instance.fromCurrency,
      'toCurrency': instance.toCurrency,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
