import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold of a page opened from another one. The back button returns to the
/// previous page, or to [fallback] when the page was opened from a link.
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.fallback,
    required this.body,
    this.actions,
  });

  final String fallback;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              context.canPop() ? context.pop() : context.go(fallback);
            },
          ),
          actions: actions,
        ),
        body: body,
      ),
    );
  }
}
