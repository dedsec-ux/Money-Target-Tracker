import 'entry.dart';

class TargetData {
  final double targetAmount;
  final List<Entry> entries;
  final String month; // e.g., '2024-06'

  TargetData({required this.targetAmount, required this.entries, required this.month});

  double get collectedAmount =>
      entries.fold(0, (sum, entry) => sum + entry.amount);

  double get remainingAmount => targetAmount - collectedAmount;

  Map<String, dynamic> toJson() => {
        'targetAmount': targetAmount,
        'entries': entries.map((e) => e.toJson()).toList(),
        'month': month,
      };

  factory TargetData.fromJson(Map<String, dynamic> json) => TargetData(
        targetAmount: (json['targetAmount'] as num).toDouble(),
        entries: (json['entries'] as List)
            .map((e) => Entry.fromJson(e))
            .toList(),
        month: json['month'] ?? '',
      );
} 