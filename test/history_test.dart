import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/history_entry.dart';
import 'package:kahwa/models/pending_kahwa.dart';

void main() {
  group('history', () {
    HistoryEntry entry(HistoryKind kind, DateTime? date) {
      return HistoryEntry(kind: kind, amount: '1 \$', date: date);
    }

    test('is newest first, with entries that have no time yet on top', () {
      final older = entry(HistoryKind.bought, DateTime(2026, 10, 1));
      final newer = entry(HistoryKind.received, DateTime(2026, 10, 2));
      final now = entry(HistoryKind.topUp, null);

      final sorted = [older, now, newer]..sort(HistoryEntry.newestFirst);

      expect(sorted, [now, newer, older]);
    });

    test('knows which way the money went', () {
      expect(entry(HistoryKind.received, null).isIncoming, isTrue);
      expect(entry(HistoryKind.topUp, null).isIncoming, isTrue);
      expect(entry(HistoryKind.bought, null).isIncoming, isFalse);
      expect(entry(HistoryKind.withdrawal, null).isIncoming, isFalse);
    });
  });

  group('a kahwa kept while topping up', () {
    test('is saved and read back the same', () {
      const pending = PendingKahwa(
        creatorId: 'c1',
        kahwas: 3,
        currency: Currency.usd,
        message: 'Keep going',
        keepPrivate: true,
      );

      final read = PendingKahwa.fromMap(pending.toMap());

      expect(read.creatorId, 'c1');
      expect(read.kahwas, 3);
      expect(read.currency, Currency.usd);
      expect(read.message, 'Keep going');
      expect(read.keepPrivate, isTrue);
    });

    test('asks to top up only what is missing', () {
      expect(missingAmount(total: 30000, balance: 10000), 20000);
      expect(missingAmount(total: 5, balance: 0), 5);
      expect(missingAmount(total: 5, balance: 5), 0);
      expect(missingAmount(total: 5, balance: 9), 0);
    });
  });
}
