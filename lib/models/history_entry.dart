/// What moved, or tried to move, the balance of a user.
enum HistoryKind { bought, received, topUp, withdrawal }

/// One line of the history of a user's balance.
class HistoryEntry {
  const HistoryEntry({
    required this.kind,
    required this.amount,
    this.date,
    this.who,
    this.kahwas = 0,
    this.status,
    this.moved = true,
  });

  final HistoryKind kind;

  /// Formatted, such as "30,000 L.L." or "150,000 L.L. and 5 $".
  final String amount;

  /// Null for something saved a moment ago, before the server gave it a time.
  final DateTime? date;

  /// The creator a kahwa was bought for, or who bought it. Null when that
  /// is private or unknown.
  final String? who;

  final int kahwas;

  /// For top ups and withdrawals: Waiting, Added, Paid, Not found or Refused.
  final String? status;

  /// Whether the balance actually changed. False for a request still
  /// waiting, refused or not found.
  final bool moved;

  /// Whether money came into the balance.
  bool get isIncoming =>
      kind == HistoryKind.received || kind == HistoryKind.topUp;

  /// Newest first, with the ones that have no time yet on top.
  static int newestFirst(HistoryEntry a, HistoryEntry b) {
    final (first, second) = (a.date, b.date);
    if (first == null || second == null) {
      return (first == null ? 0 : 1) - (second == null ? 0 : 1);
    }
    return second.compareTo(first);
  }
}
