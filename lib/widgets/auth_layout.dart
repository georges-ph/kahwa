import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/responsive.dart';

/// Layout shared by the log in, sign up and forgot password screens.
///
/// On phones and tablets the brown header with the illustration sits above
/// the form. On wide windows it becomes a panel next to the form.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.illustration,
    required this.children,
  });

  final String title;

  /// Asset path of the SVG shown in the header.
  final String illustration;

  /// The fields and buttons of the form.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: context.isExpanded ? _buildWide(context) : _buildNarrow(context),
      ),
    );
  }

  Widget _buildForm({required double maxWidth, required double padding}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final illustrationHeight = (screenHeight * 0.3).clamp(120.0, 280.0);
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: kWhiteColor,
      fontWeight: FontWeight.w800,
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          CustomPaint(
            painter: _HeaderPainter(),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(context.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: titleStyle),
                    const SizedBox(height: 16),
                    SvgPicture.asset(illustration, height: illustrationHeight),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: _buildForm(maxWidth: 480, padding: context.pagePadding),
          ),
        ],
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: ColoredBox(
            color: kBrownColor,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'kahwa',
                      style: textTheme.displayMedium?.copyWith(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buy your favorite creators a kahwa',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: kWhiteColor,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                        maxHeight: 320,
                      ),
                      child: SvgPicture.asset(illustration),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                      child: Text(title, style: textTheme.headlineLarge),
                    ),
                  ),
                  _buildForm(maxWidth: 480, padding: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Brown block with a curved bottom edge that the illustration overlaps.
class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final edge = size.height * 0.6;
    final dip = size.height * 0.1;
    final path = Path()
      ..lineTo(0, edge)
      ..quadraticBezierTo(size.width / 2, edge + dip * 2, size.width, edge)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = kBrownColor);
  }

  @override
  bool shouldRepaint(_HeaderPainter oldDelegate) => false;
}
