import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Emails kahwa sends on a tap, which a user could otherwise send again and
/// again.
enum EmailKind { passwordReset, verification }

/// Keeps a user from asking for the same email to the same address too
/// often from this device. Firebase has its own, looser, limits too.
class EmailCooldown {
  EmailCooldown(this._prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  /// How long to wait between two emails of a kind to one address.
  static const wait = Duration(minutes: 2);

  String _key(EmailKind kind, String email) =>
      'email_sent_${kind.name}_${email.trim().toLowerCase()}';

  /// How long until another one may be sent. Zero when it may be now.
  Duration remaining(EmailKind kind, String email) {
    final sent = _prefs.getInt(_key(kind, email));
    if (sent == null) return Duration.zero;
    final left = DateTime.fromMillisecondsSinceEpoch(
      sent,
    ).add(wait).difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  void markSent(EmailKind kind, String email) {
    _prefs.setInt(_key(kind, email), _now().millisecondsSinceEpoch);
  }
}

final emailCooldownProvider = Provider(
  (ref) => EmailCooldown(ref.watch(sharedPreferencesProvider)),
);
