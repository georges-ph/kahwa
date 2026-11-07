import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/features/onboarding/onboarding_screen.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// The price of a kahwa, the monthly memberships, and the thank you note.
/// Setting a price is what opens a page to kahwas.
class PricesScreen extends ConsumerWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _Prices(me: me);
  }
}

class _TierFields {
  _TierFields(Tier? tier)
    : id = tier?.id ?? 't${Random().nextInt(1 << 31).toRadixString(36)}',
      name = TextEditingController(text: tier?.name ?? ''),
      kahwas = TextEditingController(text: '${tier?.kahwas ?? 3}'),
      perks = TextEditingController(text: tier?.perks ?? '');

  final String id;
  final TextEditingController name;
  final TextEditingController kahwas;
  final TextEditingController perks;
  String? error;

  void dispose() {
    name.dispose();
    kahwas.dispose();
    perks.dispose();
  }
}

class _Prices extends ConsumerStatefulWidget {
  const _Prices({required this.me});

  final Profile me;

  @override
  ConsumerState<_Prices> createState() => _PricesState();
}

class _PricesState extends ConsumerState<_Prices> {
  late final _lbp = TextEditingController(
    text: groupDigits(widget.me.priceLbp ?? suggestedPriceLbp),
  );
  late final _usd = TextEditingController(
    text: groupDigits(widget.me.priceUsd ?? suggestedPriceUsd),
  );
  late final _thanks = TextEditingController(text: widget.me.thanks);
  late final List<_TierFields> _tiers = [
    for (final tier in widget.me.tiers) _TierFields(tier),
  ];
  String? _priceError;

  @override
  void dispose() {
    for (final c in [_lbp, _usd, _thanks]) {
      c.dispose();
    }
    for (final t in _tiers) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final lbp = parseAmount(_lbp.text);
    final usd = parseAmount(_usd.text);
    var ok = true;
    setState(() {
      _priceError = lbp == null || lbp < 1 || usd == null || usd < 1
          ? l10n.priceInvalid
          : null;
      ok = _priceError == null;
      for (final t in _tiers) {
        final kahwas = parseAmount(t.kahwas.text);
        t.error = t.name.text.trim().isEmpty
            ? l10n.tierNameMissing
            : kahwas == null || kahwas < 1 || kahwas > 1000
            ? l10n.tierKahwasInvalid
            : null;
        if (t.error != null) ok = false;
      }
    });
    if (!ok) return;

    final updated = widget.me.copyWith(
      priceLbp: () => lbp,
      priceUsd: () => usd,
      thanks: _thanks.text.trim(),
      tiers: [
        for (final t in _tiers)
          Tier(
            id: t.id,
            name: t.name.text.trim(),
            kahwas: parseAmount(t.kahwas.text)!,
            perks: t.perks.text.trim(),
          ),
      ],
    );
    try {
      await ref
          .read(profileRepositoryProvider)
          .save(updated, previousUsername: widget.me.username);
      await reloadMyProfile(ref);
      if (!mounted) return;
      showSnack(context, widget.me.isCreator ? l10n.saved : l10n.pageOpen);
      context.pop();
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lbp = parseAmount(_lbp.text) ?? 0;
    final usd = parseAmount(_usd.text) ?? 0;
    return TitledPage(
      title: l10n.pricesAndMemberships,
      maxWidth: TitledPage.wideMaxWidth,
      subtitle: widget.me.isCreator ? null : l10n.openPageSubtitle,
      bottom: BusyButton(
        label: widget.me.isCreator ? l10n.save : l10n.openMyPage,
        onPressed: _save,
      ),
      children: [
        WideColumns(
          startFlex: 2,
          endFlex: 3,
          start: [
            SectionTitle(l10n.kahwaPrice),
            Text(
              l10n.kahwaPriceHint,
              style: context.text.bodyMedium?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AmountField(
                    controller: _lbp,
                    currency: Currency.lbp,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AmountField(
                    controller: _usd,
                    currency: Currency.usd,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            if (_priceError != null) ...[
              const SizedBox(height: 6),
              Text(_priceError!, style: TextStyle(color: context.kahwa.danger)),
            ],
            const SizedBox(height: 28),
            SectionTitle(l10n.thankYouNote),
            TextField(
              controller: _thanks,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(hintText: l10n.thankYouNoteHint),
            ),
          ],
          // Memberships take the most room, so the wider column.
          end: [
            SectionTitle(l10n.memberships),
            Text(
              l10n.tiersHint,
              style: context.text.bodyMedium?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
            const SizedBox(height: 12),
            for (final (i, t) in _tiers.indexed) ...[
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.tierNumber(i + 1),
                            style: context.text.titleSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.remove,
                          onPressed: () => setState(() {
                            _tiers.removeAt(i).dispose();
                          }),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: t.name,
                      maxLength: 40,
                      decoration: InputDecoration(
                        labelText: l10n.tierName,
                        hintText: l10n.tierNameExample,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: t.kahwas,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.kahwasPerMonth,
                        helperText: l10n.tierCosts(
                          context.money(
                            (parseAmount(t.kahwas.text) ?? 0) * lbp,
                            Currency.lbp,
                          ),
                          context.money(
                            (parseAmount(t.kahwas.text) ?? 0) * usd,
                            Currency.usd,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: t.perks,
                      maxLength: 300,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.perks,
                        hintText: l10n.perksExample,
                      ),
                    ),
                    if (t.error != null)
                      Text(
                        t.error!,
                        style: TextStyle(color: context.kahwa.danger),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_tiers.length < Tier.max)
              OutlinedButton.icon(
                onPressed: () => setState(() => _tiers.add(_TierFields(null))),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addTier),
              ),
          ],
        ),
      ],
    );
  }
}
