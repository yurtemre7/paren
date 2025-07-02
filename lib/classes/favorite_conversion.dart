class FavoriteConversion {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final DateTime timestamp;

  FavoriteConversion({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': timestamp.millisecondsSinceEpoch.toString(),
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FavoriteConversion.fromJson(Map<String, dynamic> json) =>
      FavoriteConversion(
        id: json['id'],
        fromCurrency: json['fromCurrency'],
        toCurrency: json['toCurrency'],
        amount: json['amount'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
