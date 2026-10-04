import 'package:flutter/widgets.dart';

/// Window widths where layouts change, following the Material size classes.
abstract final class Breakpoints {
  /// Below this the app is on a phone in portrait.
  static const medium = 600.0;

  /// From this width there is room for two panes side by side.
  static const expanded = 960.0;
}

/// Widest a page of each kind is allowed to grow before it is centered.
abstract final class ContentWidth {
  static const form = 560.0;
  static const list = 720.0;
  static const wide = 1120.0;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isCompact => screenWidth < Breakpoints.medium;

  bool get isExpanded => screenWidth >= Breakpoints.expanded;

  /// Space between the content of a page and the edges of the window.
  double get pagePadding => isCompact ? 24 : 32;
}
