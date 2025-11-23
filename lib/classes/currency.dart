class Currency {
  final String id;
  final String name;
  final String symbol;
  final double rate;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.rate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'symbol': symbol,
    'rate': rate,
  };
}
