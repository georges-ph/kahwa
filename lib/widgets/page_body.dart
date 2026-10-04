import 'package:flutter/material.dart';
import 'package:kahwa/core/responsive.dart';

/// Scrollable body of a page. The content is centered and stops growing at
/// [maxWidth], so pages stay readable on tablets and desktops.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = ContentWidth.form,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.pagePadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Large upper case heading at the top of a page.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.upperCase = true});

  final String title;
  final bool upperCase;

  @override
  Widget build(BuildContext context) {
    return Text(
      upperCase ? title.toUpperCase() : title,
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }
}

/// Bold heading above a group of content.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
