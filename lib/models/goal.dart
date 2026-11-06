import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';

/// What a creator is saving up for. Kahwas bought in the currency of the
/// goal count towards it.
class Goal {
  const Goal({
    required this.title,
    required this.target,
    this.description = '',
    this.current = 0,
    this.currency = Currency.lbp,
    this.createdAt,
    this.endedAt,
  });

  final String title;
  final String description;
  final int target;
  final int current;
  final Currency currency;
  final DateTime? createdAt;

  /// Set on goals in the past goals list.
  final DateTime? endedAt;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);

  bool get isReached => current >= target;

  Map<String, dynamic> toNewMap() {
    return {
      'title': title,
      'description': description,
      'target': target,
      'current': 0,
      'currency': currency.name,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toPastMap() {
    return {
      'title': title,
      'description': description,
      'target': target,
      'current': current,
      'currency': currency.name,
      'created_at': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'ended_at': FieldValue.serverTimestamp(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      target: (map['target'] as num?)?.toInt() ?? 0,
      current: (map['current'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      endedAt: (map['ended_at'] as Timestamp?)?.toDate(),
    );
  }
}
