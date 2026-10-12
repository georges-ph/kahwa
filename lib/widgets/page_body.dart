import 'package:flutter/material.dart';
import 'package:kahwa/core/responsive.dart';

/// Scrollable body of a page. The content is centered and stops growing at
/// [maxWidth], so pages stay readable on tablets and desktops.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = ContentWidth.form,
    this.onRefresh,
  });

  final Widget child;
  final double maxWidth;

  /// Loads the page again. When set, the page can be pulled down to refresh.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final onRefresh = this.onRefresh;
    final scrollView = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // Short pages have to scroll too, or they cannot be pulled.
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
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

    if (onRefresh == null) return scrollView;
    // A scroll view is only as tall as what it holds. Stretch it over the
    // whole page, so a nearly empty one can be pulled from anywhere.
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SizedBox.expand(child: scrollView),
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
