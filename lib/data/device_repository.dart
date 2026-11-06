import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:kahwa/data/db.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A device the user is signed in on.
class SignedInDevice {
  const SignedInDevice({
    required this.id,
    required this.name,
    required this.platform,
    this.signedInAt,
    this.lastSeen,
  });

  final String id;

  /// Such as "Samsung SM-S918B" or "Chrome on Windows".
  final String name;

  /// `android`, `ios` or `web`.
  final String platform;
  final DateTime? signedInAt;
  final DateTime? lastSeen;

  factory SignedInDevice.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return SignedInDevice(
      id: id,
      name: map['name'] as String? ?? '',
      platform: map['platform'] as String? ?? '',
      signedInAt: (map['signed_in_at'] as Timestamp?)?.toDate(),
      lastSeen: (map['last_seen'] as Timestamp?)?.toDate(),
    );
  }
}

/// The devices a user is signed in on, kept in Firestore so they can see
/// them and sign one out from another.
///
/// kahwa has no server, so signing a device out is a request the device
/// itself carries out: its document is deleted, and the device signs out as
/// soon as it notices: when it opens or comes back to the front. It
/// does not stop someone who copied the account's tokens; changing the
/// password and turning on two-step verification does.
class DeviceRepository {
  DeviceRepository(this._db, this._prefs);

  final Db _db;
  final SharedPreferences _prefs;

  static const _idKey = 'device_id';

  /// This device's id, made once and kept on it.
  String get thisDeviceId {
    final saved = _prefs.getString(_idKey);
    if (saved != null) return saved;
    final random = Random.secure();
    final id = List.generate(
      20,
      (_) => random.nextInt(36).toRadixString(36),
    ).join();
    _prefs.setString(_idKey, id);
    return id;
  }

  static String _sessionKey(String userId) => 'device_session_$userId';

  /// Writes or refreshes this device in [userId]'s list, called when the app
  /// opens or comes back to the front. Returns false when this device was
  /// signed out from another one meanwhile, even while the app was closed:
  /// the caller then signs out here.
  ///
  /// [session] tells this sign in apart from a later one (the time the user
  /// signed in): a missing document only means "signed out elsewhere" for
  /// the sign in that registered it.
  Future<bool> checkIn(String userId, {required String session}) async {
    final ref = _db.devices(userId).doc(thisDeviceId);
    final existing = await ref.get();
    final registered = _prefs.getString(_sessionKey(userId));
    if (!existing.exists && registered == session) {
      await _prefs.remove(_sessionKey(userId));
      return false;
    }
    final (name, platform) = await _describe();
    await ref.set({
      'name': name,
      'platform': platform,
      'last_seen': FieldValue.serverTimestamp(),
      if (!existing.exists) 'signed_in_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _prefs.setString(_sessionKey(userId), session);
    return true;
  }

  Future<List<SignedInDevice>> fetch(String userId) {
    return _db.devices(userId).get().then((snapshot) {
      final far = DateTime(0);
      return [
        for (final doc in snapshot.docs)
          SignedInDevice.fromMap(doc.data(), id: doc.id),
      ]..sort((a, b) => (b.lastSeen ?? far).compareTo(a.lastSeen ?? far));
    });
  }

  Future<void> signOut(String userId, String deviceId) {
    return _db.devices(userId).doc(deviceId).delete();
  }

  /// Signs out every device but this one.
  Future<void> signOutOthers(String userId) async {
    final snapshot = await _db.devices(userId).get();
    final batch = _db.firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.id != thisDeviceId) batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Takes this device off the list, before signing out of it.
  Future<void> forget(String userId) async {
    // First, so a delete that is slow to reach Firebase is not taken for a
    // sign out from elsewhere on the next sign in.
    await _prefs.remove(_sessionKey(userId));
    await _db.devices(userId).doc(thisDeviceId).delete();
  }

  static Future<(String, String)> _describe() async {
    final info = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        final browser = switch (web.browserName) {
          BrowserName.chrome => 'Chrome',
          BrowserName.edge => 'Edge',
          BrowserName.firefox => 'Firefox',
          BrowserName.safari => 'Safari',
          BrowserName.opera => 'Opera',
          BrowserName.samsungInternet => 'Samsung Internet',
          _ => 'Browser',
        };
        final system = web.platform ?? '';
        final os = system.contains('Win')
            ? 'Windows'
            : system.contains('Mac')
            ? 'Mac'
            : system.contains('Linux')
            ? 'Linux'
            : system;
        return (os.isEmpty ? browser : '$browser · $os', 'web');
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final android = await info.androidInfo;
          final brand = android.manufacturer.isEmpty
              ? ''
              : '${android.manufacturer[0].toUpperCase()}'
                    '${android.manufacturer.substring(1)} ';
          return ('$brand${android.model}'.trim(), 'android');
        case TargetPlatform.iOS:
          final ios = await info.iosInfo;
          return (ios.name, 'ios');
        default:
          return (defaultTargetPlatform.name, defaultTargetPlatform.name);
      }
    } catch (_) {
      return (
        kIsWeb ? 'Browser' : defaultTargetPlatform.name,
        kIsWeb ? 'web' : defaultTargetPlatform.name,
      );
    }
  }
}
