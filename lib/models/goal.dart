import 'package:kahwa/models/currency.dart';

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.current = 0,
    this.currency = Currency.lbp,
  });

  /// Same as the id of the creator who owns the goal.
  final String id;
  final String title;
  final String description;
  final int current;
  final int target;

  /// Only donations made in this currency count towards the goal.
  final Currency currency;

  double get progress {
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1).toDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'current': current,
      'target': target,
      'currency': currency.name,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      current: (map['current'] as num?)?.toInt() ?? 0,
      target: (map['target'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
    );
  }
}
