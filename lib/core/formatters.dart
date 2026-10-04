/// Initials of [name], e.g. `John Doe` gives `JD`. At most two letters.
String getInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}

/// `1 Fan`, `2 Fans`.
String plural(int count, String singular, [String? pluralForm]) {
  return '$count ${pluralWord(count, singular, pluralForm)}';
}

String pluralWord(int count, String singular, [String? pluralForm]) {
  return count == 1 ? singular : pluralForm ?? '${singular}s';
}

/// Parses a whole positive number typed by a user, null when invalid.
int? parseAmount(String text) {
  final value = int.tryParse(text.trim().replaceAll(',', ''));
  return value == null || value < 0 ? null : value;
}
