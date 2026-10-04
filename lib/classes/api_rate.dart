import 'package:json_annotation/json_annotation.dart';

part 'api_rate.g.dart';

/// An exchange-rate record returned by Frankfurter's `/rates` endpoint.
@JsonSerializable()
class ApiRate {
  final DateTime date;
  final String base;
  final String quote;
  final double rate;
  final List<ApiProviderRate>? providers;

  const ApiRate({
    required this.date,
    required this.base,
    required this.quote,
    required this.rate,
    this.providers,
  });

  factory ApiRate.fromJson(Map<String, dynamic> json) =>
      _$ApiRateFromJson(json);

  Map<String, dynamic> toJson() => _$ApiRateToJson(this);
}

/// A provider's observation included when `/rates?expand=providers` is used.
@JsonSerializable()
class ApiProviderRate {
  final String key;
  final DateTime date;
  final double rate;
  final bool? excluded;

  const ApiProviderRate({
    required this.key,
    required this.date,
    required this.rate,
    this.excluded,
  });

  factory ApiProviderRate.fromJson(Map<String, dynamic> json) =>
      _$ApiProviderRateFromJson(json);

  Map<String, dynamic> toJson() => _$ApiProviderRateToJson(this);
}
