import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centers [child] and keeps it at a readable width, with the page gutter.
class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      // As tall as the child: in a bottom bar, an Align would otherwise
      // take the whole screen.
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Two columns side by side on a wide screen, one under the other on a
/// phone: [start] first, then [end]. For pages given
/// [TitledPage.wideMaxWidth], so they use the room a big screen has.
class WideColumns extends StatelessWidget {
  const WideColumns({
    super.key,
    required this.start,
    required this.end,
    this.startFlex = 3,
    this.endFlex = 2,
    this.endFirstWhenStacked = false,
  });

  final List<Widget> start;
  final List<Widget> end;
  final int startFlex;
  final int endFlex;

  /// On a phone, [end] comes before [start].
  final bool endFirstWhenStacked;

  /// Below this width the columns stack.
  static const minWidth = 760.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: endFirstWhenStacked
                ? [...end, ...start]
                : [...start, ...end],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: startFlex,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: start,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: endFlex,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: end,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A scrolling page with a big title, the layout of most screens.
/// Where a [TitledPage]'s preview goes on a phone, where there is no side
/// column.
enum PreviewOnPhone {
  /// Above the page, in sight while it scrolls.
  pinned,

  /// First on the page, scrolling with it.
  inline,

  /// Left out.
  hidden,
}

class TitledPage extends StatelessWidget {
  /// Width of pages laid out in [WideColumns] or grids on a big screen.
  static const wideMaxWidth = 1120.0;

  const TitledPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.actions = const [],
    this.maxWidth = 640,
    this.onRefresh,
    this.bottom,
    this.leading,
    this.preview,
    this.previewOnPhone = PreviewOnPhone.pinned,
    this.side = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Shows what the form changes. On a wide screen it heads a side column
  /// and stays in sight while the page scrolls; on a phone see
  /// [previewOnPhone].
  final Widget? preview;
  final PreviewOnPhone previewOnPhone;

  /// On a wide screen, the side column under [preview], scrolling on its
  /// own. On a phone, after [children].
  final List<Widget> side;
  final List<Widget> actions;
  final double maxWidth;
  final Future<void> Function()? onRefresh;

  /// Stays at the bottom of the screen, such as the main button of a form.
  final Widget? bottom;
  final Widget? leading;

  /// Whether pages are wide enough for a side column.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= WideColumns.minWidth + 40;

  @override
  Widget build(BuildContext context) {
    final hasSide = preview != null || side.isNotEmpty;
    final wide = hasSide && isWide(context);
    final heading = [
      Text(title, style: context.text.headlineMedium),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(
          subtitle!,
          style: context.text.bodyLarge?.copyWith(color: context.kahwa.muted),
        ),
      ],
      const SizedBox(height: 24),
    ];

    final Widget body;
    if (wide) {
      // Two columns that scroll apart, so the preview stays in sight.
      body = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _refreshable(
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 0, 32),
                    children: [...heading, ...children],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (preview != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 20, 16),
                        child: preview,
                      ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          preview == null ? 8 : 0,
                          20,
                          32,
                        ),
                        children: side,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final pinned = previewOnPhone == PreviewOnPhone.pinned ? preview : null;
      final list = _refreshable(
        ListView(
          padding: EdgeInsets.zero,
          children: [
            PageFrame(
              maxWidth: maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...heading,
                  if (previewOnPhone == PreviewOnPhone.inline &&
                      preview != null) ...[
                    preview!,
                    const SizedBox(height: 24),
                  ],
                  ...children,
                  ...side,
                ],
              ),
            ),
          ],
        ),
      );
      body = pinned == null
          ? list
          : Column(
              children: [
                PageFrame(
                  maxWidth: maxWidth,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: pinned,
                ),
                Expanded(child: list),
              ],
            );
    }
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        actions: [...actions, const SizedBox(width: 8)],
      ),
      body: body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: PageFrame(
                // A form button stays at a size a hand reaches, even on a wide page.
                maxWidth: maxWidth < 640 ? maxWidth : 640,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                // As wide as the page, not as its label.
                child: SizedBox(width: double.infinity, child: bottom),
              ),
            ),
    );
  }

  Widget _refreshable(Widget list) => onRefresh == null
      ? list
      : RefreshIndicator(onRefresh: onRefresh!, child: list);
}

/// A rounded card with padding.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The heading of a part of a page, with an optional action at the end.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleLarge)),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// A number with a label under it, such as "12 kahwas".
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.kahwa.subtle,
      borderRadius: BorderRadius.circular(Radii.tile),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.tile),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: context.text.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: context.kahwa.muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Tone { info, success, warning, danger }

/// A tinted box that tells the user something.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.message,
    this.title,
    this.tone = Tone.info,
    this.icon,
    this.action,
  });

  final String? title;
  final String message;
  final Tone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final k = context.kahwa;
    final (background, foreground, defaultIcon) = switch (tone) {
      Tone.info => (
        context.colors.primaryContainer,
        context.colors.onPrimaryContainer,
        Icons.info_rounded,
      ),
      Tone.success => (
        k.successContainer,
        k.success,
        Icons.check_circle_rounded,
      ),
      Tone.warning => (k.warningContainer, k.warning, Icons.schedule_rounded),
      Tone.danger => (k.dangerContainer, k.danger, Icons.error_rounded),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.tile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: foreground, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.text.titleSmall?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(message, style: context.text.bodyMedium),
                if (action != null) ...[const SizedBox(height: 8), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What a list shows when it has nothing in it: an invitation, not an
/// apology.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 34, color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: context.text.bodyMedium?.copyWith(
                color: context.kahwa.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Shows [value]: a spinner while it loads, a retry button if it failed.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: builder,
      loading: () =>
          loading ??
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, _) => ErrorView(onRetry: onRetry),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: context.l10n.loadFailed,
      message: context.l10n.loadFailedHint,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
    );
  }
}

/// A button that runs an async [onPressed] and shows a spinner meanwhile.
class BusyButton extends StatefulWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color? color;

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed == null ? null : _run;
    final content = _busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
    if (widget.outlined) {
      return OutlinedButton(onPressed: onPressed, child: content);
    }
    return FilledButton(
      onPressed: onPressed,
      style: widget.color == null
          ? null
          : FilledButton.styleFrom(backgroundColor: widget.color),
      child: content,
    );
  }
}

/// Picks LBP or USD.
class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = Currency.values,
  });

  final Currency value;
  final ValueChanged<Currency>? onChanged;
  final List<Currency> options;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Currency>(
      showSelectedIcon: false,
      segments: [
        for (final currency in options)
          ButtonSegment(
            value: currency,
            label: Text(currency.sign(arabic: context.isArabic)),
          ),
      ],
      selected: {value},
      onSelectionChanged: onChanged == null
          ? null
          : (selection) => onChanged!(selection.first),
    );
  }
}

/// A label above a field, the way every form in kahwa is laid out.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, required this.child, this.hint});

  final String label;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: context.text.titleSmall),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: context.text.bodySmall?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// The kahwa cup picture.
class KahwaCup extends StatelessWidget {
  const KahwaCup({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/cup.png', width: size, height: size);
  }
}

/// A row in a settings-like list: icon, title, optional subtitle, chevron.
class NavTile extends StatelessWidget {
  const NavTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: context.isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: tint, size: 21),
      ),
      title: Text(title, style: context.text.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: context.text.bodySmall?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: context.kahwa.muted,
                )),
    );
  }
}

/// A group of [NavTile]s in one card.
class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }
}

/// Tiles in one card on a phone, and in a grid of cards on a wide screen,
/// so long lists use the width.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.children});

  final List<Widget> children;

  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 3
            : width >= 640
            ? 2
            : 1;
        if (columns == 1) return TileGroup(children: children);
        final cell = (width - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final child in children)
              SizedBox(
                width: cell,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: child,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Asks the user to confirm. Resolves to true only on [confirm].
///
/// The other button says [dismiss], or "Cancel" when there is none, which
/// reads wrong when the action itself is cancelling something.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String confirm,
  String? dismiss,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(dismiss ?? context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: context.kahwa.dangerFill,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> openLink(BuildContext context, Uri uri) async {
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) showSnack(context, context.l10n.linkFailed);
}

/// Writes an amount with its thousands marked as it is typed: `100,000`.
/// Digits typed on an Arabic keyboard are written as the amounts are shown.
class ThousandsFormatter extends TextInputFormatter {
  const ThousandsFormatter();

  static String _digits(String text) {
    final buffer = StringBuffer();
    for (final unit in text.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.writeCharCode(unit);
      } else if (unit >= 0x660 && unit <= 0x669) {
        buffer.writeCharCode(unit - 0x660 + 0x30);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text).replaceFirst(RegExp('^0+(?=.)'), '');
    if (digits.isEmpty) return TextEditingValue.empty;
    final parsed = int.tryParse(digits);
    if (parsed == null) return oldValue;
    final text = groupDigits(parsed);

    // Keep the cursor after the same number of digits.
    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final before = _digits(newValue.text.substring(0, cursor)).length;
    var offset = 0;
    for (var seen = 0; offset < text.length && seen < before; offset++) {
      if (text[offset] != ',') seen++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// A field for an amount in [currency]: thousands marked as it is typed, and
/// the currency always in sight, even while it is empty.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.currency,
    this.errorText,
    this.autofocus = false,
    this.style,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final Currency currency;
  final String? errorText;
  final bool autofocus;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final lbp = currency == Currency.lbp;
    final mark = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        currency.sign(arabic: context.isArabic),
        style: context.text.bodyLarge?.copyWith(color: context.kahwa.muted),
      ),
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: style,
      keyboardType: TextInputType.number,
      inputFormatters: const [ThousandsFormatter()],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: '0',
        errorText: errorText,
        // Shown even when empty, unlike suffixText and prefixText.
        suffixIcon: lbp ? mark : null,
        suffixIconConstraints: const BoxConstraints(),
        prefixIcon: lbp ? null : mark,
        prefixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}

/// The "@" before a username, shown even while the field is empty.
class AtSign extends StatelessWidget {
  const AtSign({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 2),
      child: Text(
        '@',
        style: context.text.bodyLarge?.copyWith(color: context.kahwa.muted),
      ),
    );
  }
}

/// A password field with a button to show what was typed.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.newPassword = false,
    this.prefixIcon,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  /// Lets a password manager suggest a new password too.
  final bool newPassword;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: [
        AutofillHints.password,
        if (widget.newPassword) AutofillHints.newPassword,
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: IconButton(
          tooltip: _hidden ? l10n.showPassword : l10n.hidePassword,
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(
            _hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
        ),
      ),
    );
  }
}
