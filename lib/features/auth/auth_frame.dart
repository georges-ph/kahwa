import 'package:flutter/material.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/theme/palette.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/widgets.dart';

/// The layout of the sign in screens: a brand panel beside the form on wide
/// screens, a banner above it on phones.
class AuthFrame extends StatelessWidget {
  const AuthFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.headlineLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: context.text.bodyLarge?.copyWith(color: context.kahwa.muted),
        ),
        const SizedBox(height: 28),
        ...children,
      ],
    );

    if (context.isWide) {
      return Scaffold(
        appBar: AppBar(),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 0, 24),
                child: _BrandPanel(
                  borderRadius: BorderRadius.circular(Radii.card + 8),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: form,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: Brand.maroon,
            foregroundColor: Colors.white,
            flexibleSpace: const FlexibleSpaceBar(background: _BrandPanel()),
          ),
          SliverToBoxAdapter(
            child: PageFrame(
              maxWidth: 480,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: form,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.borderRadius});

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final wide = borderRadius != null;
    return CoverBanner(
      color: Brand.maroon,
      pattern: CoverPattern.waves,
      height: double.infinity,
      borderRadius: borderRadius,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(wide ? 48 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Brand.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: KahwaCup(size: wide ? 56 : 36),
              ),
              if (wide) ...[
                const SizedBox(height: 28),
                Text(
                  context.l10n.tagline,
                  style: context.text.displaySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.welcomeSubtitle,
                  style: context.text.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
