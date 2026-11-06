import 'dart:ui' show TextDirection;

import 'package:intl/intl.dart' show Bidi;

/// Initials of [name], e.g. `John Doe` gives `JD`. At most two letters.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .take(2)
      .map((word) => String.fromCharCode(word.runes.first).toUpperCase())
      .join();
}

/// The first name in [name], for friendly titles such as "Buy Nour a kahwa".
String firstNameOf(String name) {
  final first = name.trim().split(RegExp(r'\s+')).first;
  return first.isEmpty ? name : first;
}

/// Whether [text] looks like a phone number: digits, with spaces, dashes or
/// a leading `+`, and at least 7 of them (`3 123 456` is a Lebanese number).
bool isPhoneNumber(String text) {
  final trimmed = text.trim();
  if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(trimmed)) return false;
  return RegExp(r'\d').allMatches(trimmed).length >= 7;
}

/// [url] with a scheme, so `instagram.com/nour` opens as a web address.
Uri? parseLink(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  return uri;
}

/// The address of [uri] without its scheme or a trailing slash, for display.
String displayLink(Uri uri) {
  final text = '${uri.host}${uri.path}'.replaceFirst(RegExp(r'^www\.'), '');
  return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
}

/// The direction of [text] written by a user, from its first letter, so an
/// English message reads left to right in the Arabic app, and the other way
/// round.
TextDirection textDirectionOf(String text) {
  return Bidi.startsWithRtl(text) ? TextDirection.rtl : TextDirection.ltr;
}
