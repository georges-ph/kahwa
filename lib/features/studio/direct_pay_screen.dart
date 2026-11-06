import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/pick_picture.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/qr_reader.dart';
import 'package:kahwa/features/admin/admin_screen.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/widgets.dart';

/// A creator turns on payments straight to their own WHISH account.
class DirectPaySettingsScreen extends ConsumerStatefulWidget {
  const DirectPaySettingsScreen({super.key});

  @override
  ConsumerState<DirectPaySettingsScreen> createState() =>
      _DirectPaySettingsScreenState();
}

class _DirectPaySettingsScreenState
    extends ConsumerState<DirectPaySettingsScreen> {
  final _links = {
    for (final currency in Currency.values) currency: TextEditingController(),
  };
  final _errors = <Currency, String?>{};
  bool _enabled = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final controller in _links.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Reads the code of [currency] from the picture WHISH saves with "Share
  /// QR code", as WHISH shows no link to copy.
  Future<void> _readPicture(Currency currency) async {
    final l10n = context.l10n;
    final String? link;
    try {
      final bytes = await pickPicture();
      if (bytes == null) return;
      link = whishPayLink(await compute(readQrCode, bytes));
    } catch (e) {
      debugPrint('Reading the QR picture failed: $e');
      if (mounted) showSnack(context, l10n.somethingWrong);
      return;
    }
    if (!mounted) return;
    final code = link;
    if (code == null) {
      showSnack(context, l10n.directPayNoCode);
      return;
    }
    setState(() {
      _links[currency]!.text = code;
      _errors.remove(currency);
      _enabled = true;
    });
    showSnack(context, l10n.directPayCodeRead);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final links = {
      for (final MapEntry(key: currency, value: controller) in _links.entries)
        if (controller.text.trim().isNotEmpty) currency: controller.text.trim(),
    };
    final errors = <Currency, String?>{
      for (final MapEntry(key: currency, value: link) in links.entries)
        if (!isWhishPayLink(link)) currency: l10n.directPayLinkInvalid,
    };
    if (_enabled && errors.isEmpty && links.isEmpty) {
      errors[Currency.lbp] = l10n.directPayLinkMissing;
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) return;
    try {
      await ref
          .read(supportRepositoryProvider)
          .saveDirectPay(id, DirectPay(enabled: _enabled, whishLinks: links));
      ref.invalidate(directPayProvider(id));
      if (!mounted) return;
      showSnack(context, l10n.saved);
      context.pop();
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = ref.watch(userIdProvider);
    final settings = id == null ? null : ref.watch(directPayProvider(id));
    if (!_loaded && settings != null && settings.hasValue) {
      _loaded = true;
      _enabled = settings.value!.enabled;
      for (final MapEntry(key: currency, value: link)
          in settings.value!.whishLinks.entries) {
        _links[currency]!.text = link;
      }
    }
    return TitledPage(
      title: l10n.directPayTitle,
      maxWidth: TitledPage.wideMaxWidth,
      subtitle: l10n.directPaySubtitle,
      bottom: BusyButton(label: l10n.save, onPressed: _save),
      children: [
        if (!_loaded && settings != null && settings.hasError)
          ErrorView(onRetry: () => ref.invalidate(directPayProvider(id!)))
        else if (!_loaded)
          const Center(child: CircularProgressIndicator())
        else ...[
          WideColumns(
            start: [
              Panel(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  title: Text(l10n.directPaySwitch),
                  subtitle: Text(
                    l10n.directPaySwitchHint,
                    style: TextStyle(color: context.kahwa.muted),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.directPayLinksHint,
                style: context.text.bodyMedium?.copyWith(
                  color: context.kahwa.muted,
                ),
              ),
              const SizedBox(height: 16),
              for (final currency in Currency.values)
                FieldLabel(
                  l10n.directPayLinkFor(currencyName(context, currency)),
                  child: TextField(
                    controller: _links[currency],
                    enabled: _enabled,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'https://whish.money/pay/…',
                      errorText: _errors[currency],
                      prefixIcon: const Icon(Icons.link_rounded),
                      suffixIcon: IconButton(
                        tooltip: l10n.directPayFromPicture,
                        onPressed: () => _readPicture(currency),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                      ),
                    ),
                  ),
                ),
            ],
            end: [
              Notice(
                tone: Tone.warning,
                title: l10n.directPayNoticeTitle,
                message: l10n.directPayNotice,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Payments supporters sent to the creator's WHISH account: confirm the
/// ones that arrived.
class DirectPaymentsScreen extends ConsumerWidget {
  const DirectPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final payments = ref.watch(myDirectPaymentsProvider);
    return TitledPage(
      title: l10n.directPaymentsTitle,
      maxWidth: TitledPage.wideMaxWidth,
      subtitle: l10n.directPaymentsSubtitle,
      children: [
        AsyncView(
          value: payments,
          onRetry: () => ref.invalidate(myDirectPaymentsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.mark_email_read_rounded,
                title: l10n.directPaymentsEmpty,
              );
            }
            final pending = list.where((p) => p.isPending).toList();
            final answered = list.where((p) => !p.isPending).toList();
            // Side by side on a wide screen: to answer, and answered.
            return WideColumns(
              startFlex: 1,
              endFlex: 1,
              start: [
                for (final p in pending) ...[
                  DirectPaymentCard(payment: p),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 16),
              ],
              end: [
                if (answered.isNotEmpty) ...[
                  SectionTitle(l10n.answered),
                  for (final p in answered) ...[
                    DirectPaymentCard(payment: p),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A direct WHISH payment, with the buttons to answer it while it waits.
class DirectPaymentCard extends ConsumerWidget {
  const DirectPaymentCard({super.key, required this.payment});

  final DirectPayment payment;

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref, {
    required bool received,
  }) async {
    final l10n = context.l10n;
    final me = ref.read(myProfileProvider).valueOrNull;
    if (me == null) return;
    final money = context.money(payment.total, payment.currency);
    final ok = await confirm(
      context,
      title: received ? l10n.markReceived : l10n.markNotReceived,
      message: received
          ? l10n.directConfirmBody(money, payment.senderPhone)
          : l10n.directRejectBody,
      confirm: received ? l10n.received : l10n.notReceived,
      danger: !received,
    );
    if (!ok) return;
    final repo = ref.read(supportRepositoryProvider);
    try {
      if (received) {
        await repo.confirmDirectPayment(payment, me);
        refreshMyData(ref.invalidate);
      } else {
        await repo.rejectDirectPayment(payment, me);
        refreshMyData(ref.invalidate);
      }
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final supporter = ref
        .watch(profileProvider(payment.supporterId))
        .valueOrNull;
    final status = switch (payment.status) {
      DirectPaymentStatus.pending => null,
      DirectPaymentStatus.confirmed => (l10n.received, context.kahwa.success),
      DirectPaymentStatus.rejected => (l10n.notReceived, context.kahwa.danger),
    };
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: supporter, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supporter?.name ?? '',
                      style: context.text.titleMedium,
                    ),
                    Text(
                      l10n.kahwasCount(payment.kahwas),
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                context.money(payment.total, payment.currency),
                style: context.text.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          DetailRow(l10n.senderPhoneOf, payment.senderPhone, copy: true),
          DetailRow(l10n.sentAt, dateTime(context, payment.createdAt)),
          if (payment.message.isNotEmpty)
            DetailRow(l10n.message, payment.message),
          const SizedBox(height: 12),
          if (status case (final label, final color)?)
            Text(
              label,
              style: context.text.titleSmall?.copyWith(color: color),
              textAlign: TextAlign.center,
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _answer(context, ref, received: false),
                    child: Text(l10n.notReceived, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _answer(context, ref, received: true),
                    child: Text(l10n.received, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
