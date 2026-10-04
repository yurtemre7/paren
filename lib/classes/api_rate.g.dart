// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRate _$ApiRateFromJson(Map<String, dynamic> json) => ApiRate(
  date: DateTime.parse(json['date'] as String),
  base: json['base'] as String,
  quote: json['quote'] as String,
  rate: (json['rate'] as num).toDouble(),
  providers: (json['providers'] as List<dynamic>?)
      ?.map((e) => ApiProviderRate.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ApiRateToJson(ApiRate instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'base': instance.base,
  'quote': instance.quote,
  'rate': instance.rate,
  'providers': instance.providers,
};

ApiProviderRate _$ApiProviderRateFromJson(Map<String, dynamic> json) =>
    ApiProviderRate(
      key: json['key'] as String,
      date: DateTime.parse(json['date'] as String),
      rate: (json['rate'] as num).toDouble(),
      excluded: json['excluded'] as bool?,
    );

Map<String, dynamic> _$ApiProviderRateToJson(ApiProviderRate instance) =>
    <String, dynamic>{
      'key': instance.key,
      'date': instance.date.toIso8601String(),
      'rate': instance.rate,
      'excluded': instance.excluded,
    };
