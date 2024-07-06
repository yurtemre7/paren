class Currency {
  final String name;
  final String symbol;
  final String flag;
  final double rate;

  Currency({
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      name: json['name'],
      symbol: json['symbol'],
      flag: json['flag'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'flag': flag,
        'rate': rate,
      };
}
