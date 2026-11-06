import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/goal_card.dart';
import 'package:kahwa/ui/widgets.dart';

final _pastGoalsProvider = FutureProvider.autoDispose<List<Goal>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(supportRepositoryProvider).pastGoals(id);
});

/// The goal a creator is saving for: start one, edit it, end it.
class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _target = TextEditingController();
  var _currency = Currency.lbp;
  String? _titleError;
  String? _targetError;

  /// True while making a new goal, false while editing the running one.
  bool _creating = false;
  bool _filled = false;

  @override
  void dispose() {
    for (final c in [_title, _description, _target]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Goal? goal) {
    if (_filled) return;
    _filled = true;
    _creating = goal == null;
    if (goal != null) {
      _title.text = goal.title;
      _description.text = goal.description;
      _target.text = groupDigits(goal.target);
      _currency = goal.currency;
    }
  }

  Future<void> _save(Goal? running) async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final title = _title.text.trim();
    final target = parseAmount(_target.text);
    setState(() {
      _titleError = title.isEmpty ? l10n.goalTitleMissing : null;
      _targetError = target == null || target < 1
          ? l10n.goalTargetInvalid
          : null;
    });
    if (_titleError != null || _targetError != null) return;

    final repo = ref.read(supportRepositoryProvider);
    try {
      if (_creating || running == null) {
        if (running != null) {
          final ok = await confirm(
            context,
            title: l10n.replaceGoalTitle,
            message: l10n.replaceGoalBody,
            confirm: l10n.startNewGoal,
          );
          if (!ok) return;
        }
        await repo.startGoal(
          id,
          Goal(
            title: title,
            description: _description.text.trim(),
            target: target!,
            currency: _currency,
          ),
        );
      } else {
        await repo.editGoal(
          id,
          title: title,
          description: _description.text.trim(),
          target: target!,
          // Only while no kahwa counted towards it.
          currency: running.current == 0 ? _currency : null,
        );
      }
      ref.invalidate(_pastGoalsProvider);
      if (!mounted) return;
      showSnack(context, l10n.saved);
      setState(() => _creating = false);
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  Future<void> _end() async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final ok = await confirm(
      context,
      title: l10n.endGoalTitle,
      message: l10n.endGoalBody,
      confirm: l10n.endGoal,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(supportRepositoryProvider).endGoal(id);
      refreshMyData(ref.invalidate);
      ref.invalidate(_pastGoalsProvider);
      if (!mounted) return;
      setState(() {
        _creating = true;
        _title.clear();
        _description.clear();
        _target.clear();
      });
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = ref.watch(userIdProvider) ?? '';
    final goal = ref.watch(goalProvider(id));
    if (!goal.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final running = goal.value;
    _fill(running);
    final past = ref.watch(_pastGoalsProvider).valueOrNull ?? const [];
    // Kahwas already counted are in the currency of the goal.
    final currencyLocked = running != null && !_creating && running.current > 0;

    return TitledPage(
      title: l10n.goal,
      maxWidth: TitledPage.wideMaxWidth,
      subtitle: l10n.goalSubtitle,
      bottom: BusyButton(
        label: running == null || _creating ? l10n.startGoal : l10n.save,
        onPressed: () => _save(running),
      ),
      // How the goal will look on the page, as it is typed.
      preview: ListenableBuilder(
        listenable: Listenable.merge([_title, _description, _target]),
        builder: (context, _) => GoalCard(
          goal: Goal(
            title: _title.text.trim().isEmpty
                ? l10n.goalTitleExample
                : _title.text.trim(),
            description: _description.text.trim(),
            target: parseAmount(_target.text) ?? 0,
            current: _creating ? 0 : running?.current ?? 0,
            currency: _currency,
          ),
        ),
      ),
      previewOnPhone: PreviewOnPhone.inline,
      side: [
        if (running != null && !_creating) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _creating = true;
                    _title.clear();
                    _description.clear();
                    _target.clear();
                  }),
                  child: Text(l10n.startNewGoal, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _end,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.kahwa.danger,
                  ),
                  child: Text(l10n.endGoal, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ],
      children: [
        if (running != null && !_creating) SectionTitle(l10n.editGoal),
        FieldLabel(
          l10n.goalTitle,
          child: TextField(
            controller: _title,
            maxLength: 80,
            decoration: InputDecoration(
              hintText: l10n.goalTitleExample,
              errorText: _titleError,
              counterText: '',
            ),
          ),
        ),
        FieldLabel(
          l10n.goalDescription,
          child: TextField(
            controller: _description,
            maxLength: 500,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(hintText: l10n.goalDescriptionHint),
          ),
        ),
        FieldLabel(
          l10n.goalTarget,
          hint: currencyLocked
              ? l10n.goalCurrencyLocked
              : l10n.goalCurrencyHint,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AmountField(
                  controller: _target,
                  currency: _currency,
                  errorText: _targetError,
                ),
              ),
              if (!currencyLocked) ...[
                const SizedBox(width: 12),
                CurrencyToggle(
                  value: _currency,
                  onChanged: (c) => setState(() => _currency = c),
                ),
              ],
            ],
          ),
        ),
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionTitle(l10n.pastGoals),
          for (final g in past) ...[
            Opacity(opacity: 0.85, child: GoalCard(goal: g, compact: true)),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}
