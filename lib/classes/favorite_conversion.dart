import 'package:json_annotation/json_annotation.dart';

part 'favorite_conversion.g.dart';

@JsonSerializable()
class FavoriteConversion {
  final String id, fromCurrency, toCurrency;
  final double amount;
  final DateTime timestamp;
  final double? exchangeRate;

  FavoriteConversion({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    this.exchangeRate,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory FavoriteConversion.fromJson(Map<String, dynamic> json) =>
      _$FavoriteConversionFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteConversionToJson(this);
}
