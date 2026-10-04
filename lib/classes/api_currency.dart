import 'package:json_annotation/json_annotation.dart';

part 'api_currency.g.dart';

/// A currency entry returned by Frankfurter's `/currencies` endpoint.
@JsonSerializable()
class ApiCurrency {
  @JsonKey(name: 'iso_code')
  final String isoCode;

  @JsonKey(name: 'iso_numeric')
  final String? isoNumeric;

  final String name;
  final String? symbol;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  const ApiCurrency({
    required this.isoCode,
    required this.name,
    this.isoNumeric,
    this.symbol,
    this.startDate,
    this.endDate,
  });

  factory ApiCurrency.fromJson(Map<String, dynamic> json) =>
      _$ApiCurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$ApiCurrencyToJson(this);
}
