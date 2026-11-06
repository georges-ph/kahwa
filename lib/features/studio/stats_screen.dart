import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

final _membersProvider = FutureProvider.autoDispose<List<Membership>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(supportRepositoryProvider).membersOf(id);
});

enum _Period { days30, months12, all }

/// Numbers about a creator's page: kahwas over time, money received,
/// members and top supporters.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  var _period = _Period.days30;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = ref.watch(userIdProvider) ?? '';
    final donations = ref.watch(donationsToProvider(id));
    final members = ref.watch(_membersProvider).valueOrNull ?? const [];

    return TitledPage(
      title: l10n.stats,
      maxWidth: TitledPage.wideMaxWidth,
      onRefresh: () async {
        ref
          ..invalidate(donationsToProvider(id))
          ..invalidate(_membersProvider);
      },
      children: [
        SegmentedButton<_Period>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _Period.days30, label: Text(l10n.last30Days)),
            ButtonSegment(
              value: _Period.months12,
              label: Text(l10n.last12Months),
            ),
            ButtonSegment(value: _Period.all, label: Text(l10n.allTime)),
          ],
          selected: {_period},
          onSelectionChanged: (s) => setState(() => _period = s.first),
        ),
        const SizedBox(height: 20),
        AsyncView(
          value: donations,
          onRetry: () => ref.invalidate(donationsToProvider(id)),
          builder: (all) => _Body(
            donations: _inPeriod(all),
            members: members,
            period: _period,
          ),
        ),
      ],
    );
  }

  List<Donation> _inPeriod(List<Donation> all) {
    final now = DateTime.now();
    final from = switch (_period) {
      _Period.days30 => now.subtract(const Duration(days: 30)),
      _Period.months12 => DateTime(now.year - 1, now.month + 1),
      _Period.all => DateTime(0),
    };
    return all.where((d) => (d.timestamp ?? now).isAfter(from)).toList();
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.donations,
    required this.members,
    required this.period,
  });

  final List<Donation> donations;
  final List<Membership> members;
  final _Period period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final counts = PageCounts.of(donations);
    var received = const Amounts();
    for (final d in donations) {
      received = received.add(d.currency, d.total);
    }
    final now = DateTime.now();
    final paying = members.where((m) => m.isActive && m.isPaidAt(now)).toList();
    var monthly = const Amounts();
    for (final m in paying) {
      monthly = monthly.add(m.currency, m.total);
    }
    final top = SupporterSummary.of(donations).take(5).toList();
    final profiles =
        ref
            .watch(profilesProvider(ProfileIds(top.map((s) => s.supporterId))))
            .valueOrNull ??
        const {};

    final tiles = [
      (l10n.statKahwas, '${counts.kahwas}'),
      (l10n.statSupporters, '${counts.supporters}'),
      (
        l10n.receivedIn(Currency.lbp.sign(arabic: context.isArabic)),
        context.moneyCompact(received.lbp, Currency.lbp),
      ),
      (
        l10n.receivedIn(Currency.usd.sign(arabic: context.isArabic)),
        context.moneyCompact(received.usd, Currency.usd),
      ),
      (l10n.payingMembers, '${paying.length}'),
      (
        l10n.monthlyFromMembers,
        [
          if (monthly.lbp > 0 || monthly.usd == 0)
            context.moneyCompact(monthly.lbp, Currency.lbp),
          if (monthly.usd > 0) context.moneyCompact(monthly.usd, Currency.usd),
        ].join(' · '),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          // Three tiles a row on a wide screen, two on a phone.
          builder: (context, constraints) => GridView.count(
            crossAxisCount: constraints.maxWidth >= 720 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              for (final (label, value) in tiles)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.kahwa.card,
                    borderRadius: BorderRadius.circular(Radii.tile),
                    border: Border.all(color: context.kahwa.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: context.text.labelMedium?.copyWith(
                          color: context.kahwa.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(value, style: context.text.headlineSmall),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // The chart and the best supporters side by side on a wide screen.
        WideColumns(
          start: [
            SectionTitle(l10n.kahwasOverTime),
            Panel(
              padding: const EdgeInsets.fromLTRB(12, 20, 16, 8),
              child: SizedBox(
                height: 220,
                child: _KahwaChart(donations: donations, period: period),
              ),
            ),
            const SizedBox(height: 24),
          ],
          end: [
            SectionTitle(l10n.topSupporters),
            if (top.isEmpty)
              Text(
                l10n.noSupportersYet,
                style: context.text.bodyMedium?.copyWith(
                  color: context.kahwa.muted,
                ),
              )
            else
              TileGroup(
                children: [
                  for (final (i, s) in top.indexed)
                    ListTile(
                      onTap: profiles[s.supporterId] == null
                          ? null
                          : () => context.push(
                              Routes.page(profiles[s.supporterId]!),
                            ),
                      leading: SizedBox(
                        width: 74,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              child: Text(
                                '${i + 1}',
                                style: context.text.titleSmall?.copyWith(
                                  color: context.kahwa.muted,
                                ),
                              ),
                            ),
                            ProfileAvatar(
                              profile: profiles[s.supporterId],
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                      title: Text(profiles[s.supporterId]?.name ?? ''),
                      subtitle: Text(context.ago(s.last)),
                      trailing: Text(
                        l10n.kahwasCount(s.kahwas),
                        style: context.text.titleSmall,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Kahwas received per day (last 30 days) or per month (otherwise).
class _KahwaChart extends StatelessWidget {
  const _KahwaChart({required this.donations, required this.period});

  final List<Donation> donations;
  final _Period period;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daily = period == _Period.days30;
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Buckets, oldest first.
    final List<DateTime> buckets;
    if (daily) {
      final today = DateTime(now.year, now.month, now.day);
      buckets = [
        for (var i = 29; i >= 0; i--) today.subtract(Duration(days: i)),
      ];
    } else {
      var months = 12;
      if (period == _Period.all && donations.isNotEmpty) {
        final first = donations
            .map((d) => d.timestamp ?? now)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        months = ((now.year - first.year) * 12 + now.month - first.month + 1)
            .clamp(1, 36);
      }
      buckets = [
        for (var i = months - 1; i >= 0; i--) DateTime(now.year, now.month - i),
      ];
    }
    final values = List<int>.filled(buckets.length, 0);
    for (final d in donations) {
      final at = d.timestamp ?? now;
      final key = daily
          ? DateTime(at.year, at.month, at.day)
          : DateTime(at.year, at.month);
      final i = buckets.indexOf(key);
      if (i >= 0) values[i] += d.kahwas;
    }
    final maxValue = values.fold(0, (a, b) => a > b ? a : b);
    final top = maxValue == 0 ? 4.0 : (maxValue * 1.2).ceilToDouble();
    final color = context.colors.primary;
    final labelFormat = daily ? DateFormat.d(locale) : DateFormat.MMM(locale);
    final tooltipFormat = daily
        ? DateFormat.MMMd(locale)
        : DateFormat.yMMM(locale);
    final every = (buckets.length / 6).ceil();
    final barWidth = (220 / buckets.length).clamp(4.0, 18.0);

    return BarChart(
      BarChartData(
        maxY: top,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (top / 4).ceilToDouble().clamp(
            1,
            double.infinity,
          ),
          getDrawingHorizontalLine: (_) =>
              FlLine(color: context.kahwa.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (top / 4).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: context.text.labelSmall?.copyWith(
                  color: context.kahwa.muted,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i % every != 0 && i != buckets.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labelFormat.format(buckets[i]),
                    style: context.text.labelSmall?.copyWith(
                      color: context.kahwa.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => context.colors.inverseSurface,
            tooltipBorderRadius: BorderRadius.circular(10),
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${tooltipFormat.format(buckets[group.x])}\n',
              context.text.labelSmall!.copyWith(
                color: context.colors.onInverseSurface,
              ),
              children: [
                TextSpan(
                  text: context.l10n.kahwasCount(rod.toY.toInt()),
                  style: context.text.labelLarge?.copyWith(
                    color: context.colors.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        barGroups: [
          for (final (i, v) in values.indexed)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: v.toDouble(),
                  width: barWidth,
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
