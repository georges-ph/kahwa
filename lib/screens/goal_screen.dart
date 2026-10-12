import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

/// Lets creators add, edit or delete the goal shown on their page.
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  late Future<Goal?> _goal;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();

  Currency _currency = Currency.lbp;
  bool _isSaving = false;
  bool _isDeleting = false;

  String get _userId => authRepository.userId;

  @override
  void initState() {
    super.initState();
    _goal = _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<Goal?> _load() async {
    final goal = await goalRepository.getGoal(_userId);
    if (goal != null) {
      _titleController.text = goal.title;
      _descriptionController.text = goal.description;
      _targetController.text = goal.target.toString();
      _currentController.text = goal.current.toString();
      _currency = goal.currency;
    }
    return goal;
  }

  void _reload() => setState(() => _goal = _load());

  void _close() {
    context.canPop() ? context.pop() : context.go(Routes.creator(_userId));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final target = parseAmount(_targetController.text);

    if (title.isEmpty || description.isEmpty || target == null || target == 0) {
      showSnack(
        context,
        'You cannot add a goal without a title, description and target amount',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await goalRepository.saveGoal(
        Goal(
          id: _userId,
          title: title,
          description: description,
          target: target,
          current: parseAmount(_currentController.text) ?? 0,
          currency: _currency,
        ),
      );
      if (!mounted) return;
      showSnack(context, 'Saved successfully');
      _close();
    } catch (_) {
      if (mounted) showSnack(context, 'Could not save, try again');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(Goal goal) async {
    setState(() => _isDeleting = true);
    try {
      await goalRepository.archiveGoal(goal);
      if (!mounted) return;
      showSnack(context, 'Goal deleted');
      _close();
    } catch (_) {
      if (mounted) showSnack(context, 'Could not delete, try again');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.creator(_userId),
      body: AsyncBody(
        future: _goal,
        onRetry: _reload,
        builder: (context, goal) {
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  goal == null ? 'Add New Goal' : 'Edit Goal',
                  upperCase: false,
                ),
                const SizedBox(height: 40),
                InputText(
                  controller: _titleController,
                  title: 'Goal Title',
                  hint: 'New camera',
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _descriptionController,
                  title: 'Goal Description',
                  hint: 'Enter a description for your goal',
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                const SectionTitle('Currency'),
                const SizedBox(height: 8),
                const Text('Only kahwas bought in this currency count.'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final currency in Currency.values)
                      ChoiceChip(
                        label: Text(currency.code),
                        selected: _currency == currency,
                        onSelected: (_) {
                          setState(() => _currency = currency);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _targetController,
                  title: 'Target Amount',
                  hint: '0',
                  prefixText: _currency.code,
                  digitsOnly: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                InputText(
                  controller: _currentController,
                  title: 'Current Amount',
                  hint: '0',
                  prefixText: _currency.code,
                  digitsOnly: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Save',
                  isLoading: _isSaving,
                  onPressed: _isDeleting ? null : _save,
                ),
                if (goal != null) ...[
                  const SizedBox(height: 16),
                  LoadingButton(
                    label: 'Delete Goal',
                    outlined: true,
                    isLoading: _isDeleting,
                    onPressed: _isSaving ? null : () => _delete(goal),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
