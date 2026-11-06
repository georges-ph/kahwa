import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/data/device_repository.dart';
import 'package:kahwa/features/me/settings_screen.dart';
import 'package:kahwa/state/email_cooldown.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Signs out on this device, and takes it off the user's list of devices.
Future<void> signOutHere(WidgetRef ref) async {
  final id = ref.read(userIdProvider);
  if (id != null) {
    // Not worth keeping the user in for: the list tidies itself when this
    // device's entry is found stale.
    await ref
        .read(deviceRepositoryProvider)
        .forget(id)
        .timeout(const Duration(seconds: 4))
        .catchError((_) {});
  }
  await ref.read(authRepositoryProvider).signOut();
}

/// Asks for the 6 digit code of the user's authenticator app. Null when
/// they cancel.
Future<String?> askForCode(BuildContext context, {String? message}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CodeDialog(message: message),
  );
}

class _CodeDialog extends StatefulWidget {
  const _CodeDialog({this.message});

  final String? message;

  @override
  State<_CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<_CodeDialog> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = context.l10n.codeInvalid);
      return;
    }
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.twoStepCodeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message ?? l10n.twoStepCodeBody),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _submit(),
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '000000',
              errorText: _error,
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.continueAction)),
      ],
    );
  }
}

/// Asks for the current password, with a button to show it. Null when the
/// user cancels.
Future<String?> askForPassword(BuildContext context, {String? message}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PasswordDialog(message: message),
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({this.message});

  final String? message;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text.isEmpty) {
      setState(() => _error = context.l10n.passwordMissing);
      return;
    }
    Navigator.pop(context, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.confirmItsYou),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message ?? l10n.confirmItsYouBody),
          const SizedBox(height: 16),
          PasswordField(
            controller: _password,
            autofocus: true,
            labelText: l10n.currentPassword,
            errorText: _error,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.continueAction)),
      ],
    );
  }
}

/// Checks it is really the user before a change to their account: their
/// [password] (asked for when not given), or their Google account, then the
/// code of their authenticator app when two-step verification is on.
///
/// Returns false when they cancel. A wrong password or code throws the
/// [FirebaseAuthException], for the caller to show.
Future<bool> confirmIdentity(
  BuildContext context,
  WidgetRef ref, {
  String? password,
}) async {
  final auth = ref.read(authRepositoryProvider);
  var typed = password;
  if (auth.hasPassword && typed == null) {
    typed = await askForPassword(context);
    if (typed == null) return false;
  }
  try {
    await auth.confirmIdentity(password: typed);
  } on FirebaseAuthMultiFactorException catch (e) {
    if (!context.mounted) return false;
    final code = await askForCode(context);
    if (code == null) return false;
    await auth.finishTwoStepCheck(e, code);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) return false;
    rethrow;
  }
  return true;
}

/// The message for a failed [confirmIdentity].
String identityError(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'wrong-password' || 'invalid-credential' => l10n.passwordWrong,
      'invalid-verification-code' => l10n.codeWrong,
      'too-many-requests' => l10n.tooManyAttempts,
      'network-request-failed' => l10n.noInternet,
      _ => l10n.somethingWrong,
    };
  }
  return l10n.somethingWrong;
}

/// Sends an email of [kind] to [email] with [send], unless one was sent
/// moments ago. Tells the user either way.
Future<void> sendLimitedEmail(
  BuildContext context,
  WidgetRef ref, {
  required EmailKind kind,
  required String email,
  required Future<void> Function() send,
  required String sentMessage,
}) async {
  final l10n = context.l10n;
  final cooldown = ref.read(emailCooldownProvider);
  final left = cooldown.remaining(kind, email);
  if (left > Duration.zero) {
    showSnack(context, l10n.emailWait(left.inSeconds + 1));
    return;
  }
  try {
    await send();
    cooldown.markSent(kind, email);
    if (context.mounted) showSnack(context, sentMessage);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showSnack(
      context,
      e.code == 'too-many-requests'
          ? l10n.tooManyAttempts
          : l10n.somethingWrong,
    );
  } catch (_) {
    if (context.mounted) showSnack(context, l10n.somethingWrong);
  }
}

/// Asks to send the link that verifies the user's email.
Future<void> sendVerification(BuildContext context, WidgetRef ref) {
  final auth = ref.read(authRepositoryProvider);
  final email = auth.email;
  // An account with no email at all, such as some old Google ones, adds one
  // first: the link goes to it.
  if (email == null) return showChangeEmailDialog(context);
  return sendLimitedEmail(
    context,
    ref,
    kind: EmailKind.verification,
    email: email,
    send: auth.sendVerificationEmail,
    sentMessage: context.l10n.verificationSent(email),
  );
}

/// Before money moves: makes sure the user verified their email, and offers
/// to send the link when not. Returns whether they may go on.
Future<bool> requireVerifiedEmail(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authRepositoryProvider);
  if (auth.emailVerified) return true;
  // They may have opened the link since the app started.
  if (await auth.refreshVerified()) {
    ref.invalidate(emailVerifiedProvider);
    return true;
  }
  if (!context.mounted) return false;
  final l10n = context.l10n;
  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.mark_email_unread_rounded),
      title: Text(l10n.verifyEmailTitle),
      content: Text(l10n.verifyEmailBody(auth.email ?? '')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'check'),
          child: Text(l10n.iVerified),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'send'),
          child: Text(l10n.sendLink),
        ),
      ],
    ),
  );
  if (!context.mounted) return false;
  switch (action) {
    case 'send':
      await sendVerification(context, ref);
    case 'check':
      if (await auth.refreshVerified()) {
        ref.invalidate(emailVerifiedProvider);
        return true;
      }
      if (context.mounted) showSnack(context, l10n.notVerifiedYet);
  }
  return false;
}

/// Email, password and two-step verification.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    // Picks up a verification link opened elsewhere.
    ref.read(authRepositoryProvider).refreshVerified().then((ok) {
      if (ok && mounted) ref.invalidate(emailVerifiedProvider);
      if (mounted) setState(() {});
    }).ignore();
  }

  Future<void> _changePassword() async {
    final l10n = context.l10n;
    final result = await showDialog<_PasswordResult>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (!mounted || result == null) return;
    if (result == _PasswordResult.forgot) return _emailResetLink();
    showSnack(context, l10n.passwordChanged);
  }

  /// For a user who forgot their current password: a link to set a new one.
  Future<void> _emailResetLink() async {
    final l10n = context.l10n;
    final auth = ref.read(authRepositoryProvider);
    final email = auth.email;
    if (email == null) return;
    final ok = await confirm(
      context,
      title: l10n.changePasswordTitle,
      message: l10n.changePasswordBody(email),
      confirm: l10n.sendLink,
    );
    if (!ok || !mounted) return;
    await sendLimitedEmail(
      context,
      ref,
      kind: EmailKind.passwordReset,
      email: email,
      send: () => auth.sendPasswordResetEmail(email),
      sentMessage: l10n.resetSent(email),
    );
  }

  Future<void> _turnOnTwoStep() async {
    final l10n = context.l10n;
    final auth = ref.read(authRepositoryProvider);
    if (!await requireVerifiedEmail(context, ref) || !mounted) return;
    try {
      if (!await confirmIdentity(context, ref) || !mounted) return;
      final TotpSecret secret;
      try {
        secret = await auth.startTotp();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'network-request-failed') rethrow;
        // Most often the Firebase project does not allow authenticator apps.
        debugPrint('Two-step setup failed: ${e.code} ${e.message}');
        if (mounted) showSnack(context, l10n.twoStepUnavailable);
        return;
      } catch (e) {
        debugPrint('Two-step setup failed: $e');
        if (mounted) showSnack(context, l10n.twoStepUnavailable);
        return;
      }
      if (!mounted) return;
      final done = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _TotpSetupDialog(secret: secret, email: auth.email),
      );
      if (done == true && mounted) {
        ref.invalidate(secondFactorsProvider);
        showSnack(context, l10n.twoStepOn);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showSnack(
        context,
        e.code == 'operation-not-allowed' ||
                e.code == 'admin-restricted-operation'
            ? l10n.twoStepUnavailable
            : identityError(context, e),
      );
    } catch (e) {
      if (mounted) showSnack(context, identityError(context, e));
    }
  }

  Future<void> _turnOffTwoStep(MultiFactorInfo factor) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.twoStepOffTitle,
      message: l10n.twoStepOffBody,
      confirm: l10n.turnOff,
      danger: true,
    );
    if (!ok || !mounted) return;
    try {
      if (!await confirmIdentity(context, ref) || !mounted) return;
      await ref.read(authRepositoryProvider).removeSecondFactor(factor);
      ref.invalidate(secondFactorsProvider);
      if (mounted) showSnack(context, l10n.twoStepOff);
    } catch (e) {
      if (mounted) showSnack(context, identityError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authRepositoryProvider);
    final verified =
        ref.watch(emailVerifiedProvider).valueOrNull ?? auth.emailVerified;
    final factors = ref.watch(secondFactorsProvider);

    return TitledPage(
      title: l10n.security,
      subtitle: l10n.securitySubtitle,
      children: [
        SectionTitle(l10n.email),
        Panel(
          // Changes the email, or adds one to an account that has none, as
          // the row in Settings does.
          onTap: () => showChangeEmailDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    verified
                        ? Icons.verified_rounded
                        : Icons.mark_email_unread_rounded,
                    color: verified
                        ? context.kahwa.success
                        : context.kahwa.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.email ?? l10n.noEmailYet,
                          style: context.text.titleSmall,
                        ),
                        Text(
                          verified ? l10n.emailVerified : l10n.emailNotVerified,
                          style: context.text.bodySmall?.copyWith(
                            color: context.kahwa.muted,
                          ),
                        ),
                        if (auth.email != null)
                          Text(
                            l10n.tapToChangeEmail,
                            style: context.text.bodySmall?.copyWith(
                              color: context.kahwa.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!verified) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final ok = await auth.refreshVerified();
                          if (!context.mounted) return;
                          if (ok) ref.invalidate(emailVerifiedProvider);
                          if (!ok) showSnack(context, l10n.notVerifiedYet);
                          setState(() {});
                        },
                        child: Text(
                          l10n.iVerified,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => sendVerification(context, ref),
                        child: Text(l10n.sendLink, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Two-step needs the Firebase project upgraded to Identity Platform;
        // hidden until then.
        if (AppConfig.twoStepEnabled) ...[
          const SizedBox(height: 24),
          SectionTitle(l10n.twoStep),
          AsyncView(
            value: factors,
            onRetry: () => ref.invalidate(secondFactorsProvider),
            builder: (list) {
              final on = list.isNotEmpty;
              return Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          on ? Icons.lock_rounded : Icons.lock_open_rounded,
                          color: on
                              ? context.kahwa.success
                              : context.kahwa.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            on ? l10n.twoStepIsOn : l10n.twoStepIsOff,
                            style: context.text.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.twoStepExplain,
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (on)
                      for (final factor in list)
                        OutlinedButton(
                          onPressed: () => _turnOffTwoStep(factor),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.kahwa.danger,
                          ),
                          child: Text(l10n.turnOff),
                        )
                    else
                      FilledButton(
                        onPressed: _turnOnTwoStep,
                        child: Text(l10n.turnOn),
                      ),
                    if (on) ...[
                      const SizedBox(height: 12),
                      Notice(
                        tone: Tone.warning,
                        message: l10n.twoStepBackup,
                        icon: Icons.backup_rounded,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
        // Google accounts have no password here: Google signs them in.
        if (auth.hasPassword) ...[
          const SizedBox(height: 24),
          SectionTitle(l10n.password),
          TileGroup(
            children: [
              NavTile(
                icon: Icons.lock_reset_rounded,
                title: l10n.changePassword,
                subtitle: l10n.changePasswordHint,
                onTap: _changePassword,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Shows the QR code and the key to add to an authenticator app, then asks
/// for a code from it to finish.
class _TotpSetupDialog extends ConsumerStatefulWidget {
  const _TotpSetupDialog({required this.secret, required this.email});

  final TotpSecret secret;
  final String? email;

  @override
  ConsumerState<_TotpSetupDialog> createState() => _TotpSetupDialogState();
}

class _TotpSetupDialogState extends ConsumerState<_TotpSetupDialog> {
  final _code = TextEditingController();
  String? _url;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.secret
        .generateQrCodeUrl(accountName: widget.email, issuer: 'kahwa')
        .then((url) {
          if (mounted) setState(() => _url = url);
        })
        .ignore();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = l10n.codeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).finishTotp(widget.secret, code);
      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = identityError(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPhone =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final key = widget.secret.secretKey;
    return AlertDialog(
      title: Text(l10n.twoStepSetupTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.twoStepSetupBody),
            const SizedBox(height: 16),
            if (_url != null) ...[
              if (isPhone)
                OutlinedButton.icon(
                  onPressed: () => widget.secret.openInOtpApp(_url!),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l10n.openAuthenticator),
                ),
              if (isPhone) const SizedBox(height: 12),
              Center(
                child: QrImageView(
                  data: _url!,
                  size: 180,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(l10n.twoStepKey, style: context.text.labelMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    key,
                    style: context.text.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: key));
                    showSnack(context, l10n.copied);
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _finish(),
              decoration: InputDecoration(
                labelText: l10n.twoStepCodeLabel,
                hintText: '000000',
                errorText: _error,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _finish,
          child: Text(l10n.turnOn),
        ),
      ],
    );
  }
}

/// Where the account is signed in, and signing those devices out.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    SignedInDevice device,
  ) async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final ok = await confirm(
      context,
      title: l10n.signOutDeviceTitle(device.name),
      message: l10n.signOutDeviceBody,
      confirm: l10n.signOut,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(deviceRepositoryProvider).signOut(id, device.id);
      refreshMyData(ref.invalidate);
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  Future<void> _signOutOthers(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final ok = await confirm(
      context,
      title: l10n.signOutOthersTitle,
      message: l10n.signOutDeviceBody,
      confirm: l10n.signOutOthers,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(deviceRepositoryProvider).signOutOthers(id);
      refreshMyData(ref.invalidate);
      if (context.mounted) showSnack(context, l10n.signedOutOthers);
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final devices = ref.watch(myDevicesProvider);
    final here = ref.read(deviceRepositoryProvider).thisDeviceId;

    return TitledPage(
      title: l10n.devices,
      subtitle: l10n.devicesSubtitle,
      children: [
        AsyncView(
          value: devices,
          onRetry: () => ref.invalidate(myDevicesProvider),
          builder: (list) {
            final others = list.where((d) => d.id != here).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TileGroup(
                  children: [
                    for (final d in list)
                      NavTile(
                        icon: switch (d.platform) {
                          'web' => Icons.language_rounded,
                          'ios' => Icons.phone_iphone_rounded,
                          _ => Icons.phone_android_rounded,
                        },
                        title: d.name.isEmpty ? l10n.unknownDevice : d.name,
                        subtitle: d.id == here
                            ? l10n.thisDevice
                            : l10n.lastActive(context.ago(d.lastSeen)),
                        trailing: d.id == here
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: context.kahwa.success,
                              )
                            : TextButton(
                                onPressed: () => _signOut(context, ref, d),
                                style: TextButton.styleFrom(
                                  foregroundColor: context.kahwa.danger,
                                ),
                                child: Text(l10n.signOut),
                              ),
                      ),
                  ],
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _signOutOthers(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.kahwa.danger,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.signOutOthers),
                  ),
                ],
                const SizedBox(height: 16),
                Notice(
                  message: AppConfig.twoStepEnabled
                      ? l10n.devicesNoteTwoStep
                      : l10n.devicesNote,
                  icon: Icons.info_outline_rounded,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum _PasswordResult { changed, forgot }

/// Asks for the current password and a new one, and sets it.
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  String? _currentError;
  String? _newError;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _currentError = _current.text.isEmpty ? l10n.passwordMissing : null;
      _newError = _new.text.length < 6 ? l10n.passwordShort : null;
    });
    if (_currentError != null || _newError != null) return;
    setState(() => _busy = true);
    try {
      if (!await confirmIdentity(context, ref, password: _current.text)) {
        return;
      }
      await ref.read(authRepositoryProvider).updatePassword(_new.text);
      if (mounted) Navigator.pop(context, _PasswordResult.changed);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'wrong-password' || 'invalid-credential':
            _currentError = l10n.currentPasswordWrong;
          case 'weak-password':
            _newError = l10n.passwordShort;
          default:
            showSnack(context, identityError(context, e));
        }
      });
    } catch (e) {
      if (mounted) showSnack(context, identityError(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordField(
            controller: _current,
            autofocus: true,
            enabled: !_busy,
            labelText: l10n.currentPassword,
            errorText: _currentError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _new,
            enabled: !_busy,
            newPassword: true,
            labelText: l10n.newPassword,
            hintText: l10n.passwordFieldHint,
            errorText: _newError,
            onSubmitted: (_) => _submit(),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.pop(context, _PasswordResult.forgot),
              child: Text(l10n.forgotPassword),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(l10n.save)),
      ],
    );
  }
}
