import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/core/username.dart';
import 'package:kahwa/data/profile_repository.dart';
import 'package:kahwa/features/studio/page_editors.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/theme/palette.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/widgets.dart';

/// Suggested price of a kahwa, about what one costs in a Beirut café.
const suggestedPriceLbp = 100000;
const suggestedPriceUsd = 1;

enum _Step { name, look, role, creator }

/// The first setup after signing up: a name, a look, and whether the user
/// makes things or is here to support.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  var _step = _Step.name;
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _tagline = TextEditingController();
  final _priceLbp = TextEditingController(text: groupDigits(suggestedPriceLbp));
  final _priceUsd = TextEditingController(text: '$suggestedPriceUsd');
  String? _nameError;
  String? _usernameError;
  String? _priceError;
  String? _emoji;
  int _color = creatorColors.first.toARGB32();
  var _cover = CoverPattern.dots;
  CreatorCategory? _category;
  bool _started = false;

  @override
  void dispose() {
    for (final c in [_name, _username, _tagline, _priceLbp, _priceUsd]) {
      c.dispose();
    }
    super.dispose();
  }

  void _start(Profile me) {
    if (_started) return;
    _started = true;
    _name.text = me.name;
    _username.text = me.username ?? '';
    _emoji = me.emoji ?? '☕';
    _color = me.color;
    _cover = CoverPattern.of(me.cover == 0 ? 1 : me.cover);
  }

  Future<void> _next(Profile me) async {
    final l10n = context.l10n;
    switch (_step) {
      case _Step.name:
        final name = _name.text.trim();
        final username = Username.normalize(_username.text);
        var problem = username.isEmpty ? null : Username.validate(username);
        if (problem == null && username.isNotEmpty) {
          final holder = await ref
              .read(profileRepositoryProvider)
              .idOfUsername(username);
          if (holder != null && holder != me.id) {
            problem = UsernameProblem.taken;
          }
        }
        if (!mounted) return;
        setState(() {
          _nameError = name.isEmpty ? l10n.nameMissing : null;
          _usernameError = problem == null
              ? null
              : usernameProblem(context, problem);
        });
        if (_nameError == null && _usernameError == null) {
          setState(() => _step = _Step.look);
        }
      case _Step.look:
        setState(() => _step = _Step.role);
      case _Step.role:
        break;
      case _Step.creator:
        final lbp = parseAmount(_priceLbp.text);
        final usd = parseAmount(_priceUsd.text);
        if (lbp == null || lbp < 1 || usd == null || usd < 1) {
          setState(() => _priceError = l10n.priceInvalid);
          return;
        }
        await _finish(me, creator: true);
    }
  }

  Future<void> _finish(Profile me, {required bool creator}) async {
    final username = Username.normalize(_username.text);
    final profile = me.copyWith(
      name: _name.text.trim(),
      username: () => username.isEmpty ? null : username,
      emoji: () => _emoji,
      color: _color,
      cover: _cover.index,
      tagline: creator ? _tagline.text.trim() : null,
      category: creator ? () => _category : null,
      priceLbp: creator ? () => parseAmount(_priceLbp.text) : null,
      priceUsd: creator ? () => parseAmount(_priceUsd.text) : null,
      onboarded: true,
    );
    try {
      await ref
          .read(profileRepositoryProvider)
          .save(profile, previousUsername: me.username);
      // The router still holds the profile read before the setup, and would
      // send the user back here.
      await reloadMyProfile(ref);
      if (mounted) context.go(creator ? Routes.me : Routes.explore);
    } on UsernameTakenException {
      if (!mounted) return;
      setState(() {
        _step = _Step.name;
        _usernameError = usernameProblem(context, UsernameProblem.taken);
      });
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    }
  }

  void _back() {
    setState(() {
      _step = switch (_step) {
        _Step.name || _Step.look => _Step.name,
        _Step.role => _Step.look,
        _Step.creator => _Step.role,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _start(me);
    final l10n = context.l10n;
    final stepIndex = _step.index.clamp(0, 2);

    final (title, subtitle, body) = switch (_step) {
      _Step.name => (l10n.setupNameTitle, l10n.setupNameSubtitle, _nameStep()),
      _Step.look => (l10n.setupLookTitle, l10n.setupLookSubtitle, _lookStep()),
      _Step.role => (
        l10n.setupRoleTitle,
        l10n.setupRoleSubtitle,
        _roleStep(me),
      ),
      _Step.creator => (
        l10n.setupCreatorTitle,
        l10n.setupCreatorSubtitle,
        _creatorStep(),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        leading: _step == _Step.name
            ? null
            : IconButton(
                onPressed: _back,
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  decoration: BoxDecoration(
                    color: i <= stepIndex
                        ? context.colors.primary
                        : context.kahwa.subtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // The look step keeps its preview in sight while the pickers
          // under it scroll, so every change shows at once.
          if (_step == _Step.look)
            PageFrame(
              maxWidth: 560,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PagePreview(
                name: _name.text.trim(),
                color: Color(_color),
                cover: _cover,
                emoji: _emoji,
                initials: initialsOf(_name.text),
              ),
            ),
          Expanded(
            child: ListView(
              // A new step starts at its top.
              key: ValueKey(_step),
              children: [
                PageFrame(
                  maxWidth: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(title, style: context.text.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: context.text.bodyLarge?.copyWith(
                          color: context.kahwa.muted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      body,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _step == _Step.role
          ? null
          : SafeArea(
              child: PageFrame(
                maxWidth: 560,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: BusyButton(
                    label: _step == _Step.creator ? l10n.openMyPage : l10n.next,
                    onPressed: () => _next(me),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _nameStep() {
    final l10n = context.l10n;
    return Column(
      children: [
        FieldLabel(
          l10n.yourName,
          child: TextField(
            controller: _name,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'John Doe',
              errorText: _nameError,
              counterText: '',
            ),
          ),
        ),
        FieldLabel(
          l10n.username,
          hint: l10n.usernameHint,
          child: TextField(
            controller: _username,
            maxLength: Username.maxLength + 1,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIcon: const AtSign(),
              prefixIconConstraints: const BoxConstraints(),
              hintText: 'johndoe',
              errorText: _usernameError,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _lookStep() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(
          l10n.avatar,
          child: EmojiPicker(
            value: _emoji,
            initials: initialsOf(_name.text),
            onChanged: (e) => setState(() => _emoji = e),
          ),
        ),
        FieldLabel(
          l10n.pageColor,
          child: ColorPicker(
            value: _color,
            onChanged: (c) => setState(() => _color = c),
          ),
        ),
        FieldLabel(
          l10n.bannerPattern,
          child: PatternPicker(
            value: _cover,
            color: Color(_color),
            onChanged: (p) => setState(() => _cover = p),
          ),
        ),
      ],
    );
  }

  Widget _roleStep(Profile me) {
    final l10n = context.l10n;
    Widget choice(IconData icon, String title, String body, VoidCallback tap) {
      return Panel(
        onTap: tap,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: context.colors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kahwa.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        choice(
          Icons.brush_rounded,
          l10n.roleCreatorTitle,
          l10n.roleCreatorBody,
          () => setState(() => _step = _Step.creator),
        ),
        const SizedBox(height: 12),
        choice(
          Icons.favorite_rounded,
          l10n.roleSupporterTitle,
          l10n.roleSupporterBody,
          () => _finish(me, creator: false),
        ),
      ],
    );
  }

  Widget _creatorStep() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(
          l10n.taglineLabel,
          hint: l10n.taglineHint,
          child: TextField(
            controller: _tagline,
            maxLength: 120,
            decoration: InputDecoration(
              hintText: l10n.taglineExample,
              counterText: '',
            ),
          ),
        ),
        FieldLabel(
          l10n.whatYouMake,
          child: CategoryPicker(
            value: _category,
            onChanged: (c) => setState(() => _category = c),
          ),
        ),
        FieldLabel(
          l10n.kahwaPrice,
          hint: l10n.kahwaPriceHint,
          child: Row(
            children: [
              Expanded(
                child: AmountField(
                  controller: _priceLbp,
                  currency: Currency.lbp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AmountField(
                  controller: _priceUsd,
                  currency: Currency.usd,
                ),
              ),
            ],
          ),
        ),
        if (_priceError != null)
          Text(_priceError!, style: TextStyle(color: context.kahwa.danger)),
      ],
    );
  }
}
