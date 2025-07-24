class Entry {
  final double amount;
  final DateTime dateTime;

  Entry({required this.amount, required this.dateTime});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        amount: json['amount'],
        dateTime: DateTime.parse(json['dateTime']),
      );
} 