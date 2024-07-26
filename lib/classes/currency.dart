class Currency {
  final String id;
  final String name;
  final String symbol;
  final String flag;
  final double rate;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      flag: json['flag'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'flag': flag,
        'rate': rate,
      };
}
