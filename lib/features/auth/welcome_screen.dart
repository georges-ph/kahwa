import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/settings.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/theme/palette.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/widgets.dart';

/// Whether the intro was seen on this device. It only shows on first start.
const introSeenKey = 'intro_seen';

/// The first thing a new user sees: a few slides on what kahwa is, then the
/// sign in. Shown once per device.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _leave(String location) {
    ref.read(sharedPreferencesProvider).setBool(introSeenKey, true);
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = [
      _Slide(
        art: const KahwaCup(size: 132),
        pattern: CoverPattern.rings,
        title: l10n.tagline,
        body: l10n.welcomeSubtitle,
      ),
      _Slide(
        art: const _SlideIcon(Icons.coffee_rounded),
        pattern: CoverPattern.dots,
        title: l10n.featureKahwaTitle,
        body: l10n.featureKahwaBody,
      ),
      _Slide(
        art: const _SlideIcon(Icons.workspace_premium_rounded),
        pattern: CoverPattern.waves,
        title: l10n.featureMembersTitle,
        body: l10n.featureMembersBody,
      ),
      _Slide(
        art: const _SlideIcon(Icons.auto_awesome_rounded),
        pattern: CoverPattern.rings,
        title: l10n.featurePageTitle,
        body: l10n.featurePageBody,
      ),
      _Slide(
        art: const _SlideIcon(Icons.account_balance_wallet_rounded),
        pattern: CoverPattern.dots,
        title: l10n.howItWorks,
        steps: [l10n.step1, l10n.step2, l10n.step3],
      ),
    ];
    final last = _page == slides.length - 1;

    final topBar = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          const _LanguageButton(),
          const Spacer(),
          if (!last)
            TextButton(
              onPressed: () => _leave(Routes.signIn),
              child: Text(l10n.skip),
            ),
        ],
      ),
    );
    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < slides.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _page ? context.colors.primary : context.kahwa.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
    final buttons = [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: last
                ? () => _leave(Routes.signIn)
                : () => _pages.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  ),
            child: Text(last ? l10n.getStarted : l10n.next),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextButton(
          onPressed: () => _leave(Routes.explore),
          child: Text(l10n.lookAroundFirst),
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // On a wide screen the art takes the left half, full height, and
            // the words and buttons the right half.
            if (constraints.maxWidth >= 900) {
              final slide = slides[_page];
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: CoverBanner(
                          key: ValueKey(_page),
                          color: Brand.maroon,
                          pattern: slide.pattern,
                          height: double.infinity,
                          borderRadius: BorderRadius.circular(Radii.card + 8),
                          child: Center(
                            child: Transform.scale(
                              scale: 1.8,
                              child: slide.art,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            children: [
                              topBar,
                              Expanded(
                                child: PageView(
                                  controller: _pages,
                                  onPageChanged: (i) =>
                                      setState(() => _page = i),
                                  children: [
                                    for (final s in slides)
                                      Center(child: s.withoutArt()),
                                  ],
                                ),
                              ),
                              dots,
                              ...buttons,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    topBar,
                    Expanded(
                      child: PageView(
                        controller: _pages,
                        onPageChanged: (i) => setState(() => _page = i),
                        children: slides,
                      ),
                    ),
                    dots,
                    ...buttons,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.art,
    required this.pattern,
    required this.title,
    this.body,
    this.steps = const [],
    this.showArt = true,
  });

  final Widget art;
  final CoverPattern pattern;
  final String title;
  final String? body;
  final List<String> steps;
  final bool showArt;

  /// The same slide without its banner, for wide screens, where the banner
  /// is shown beside the words.
  _Slide withoutArt() => _Slide(
    art: art,
    pattern: pattern,
    title: title,
    body: body,
    steps: steps,
    showArt: false,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: showArt
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (showArt) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.card),
              child: CoverBanner(
                color: Brand.maroon,
                pattern: pattern,
                height: 240,
                child: Center(child: art),
              ),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            title,
            style: showArt
                ? context.text.headlineMedium
                : context.text.displaySmall,
            textAlign: showArt ? TextAlign.center : TextAlign.start,
          ),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(
              body!,
              style: context.text.bodyLarge?.copyWith(
                color: context.kahwa.muted,
              ),
              textAlign: showArt ? TextAlign.center : TextAlign.start,
            ),
          ],
          for (final (i, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(step, style: context.text.bodyLarge),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SlideIcon extends StatelessWidget {
  const _SlideIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: Brand.cream,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 56, color: Brand.maroon),
    );
  }
}

/// Switches the language before signing in.
class _LanguageButton extends ConsumerWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      onSelected: (code) =>
          ref.read(settingsProvider.notifier).setLocale(Locale(code)),
      itemBuilder: (context) => [
        for (final MapEntry(key: code, value: name)
            in AppSettings.languageNames.entries)
          CheckedPopupMenuItem(
            value: code,
            checked: code == current,
            child: Text(name),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate_rounded,
              size: 20,
              color: context.colors.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              AppSettings.languageNames[current] ?? '',
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
