import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shows a spinner while [future] loads, an error message if it fails and
/// the result of [builder] once it is done.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error!, onRetry: onRetry);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

/// Thrown by screens when the signed in user may not see a page.
FirebaseException accessDenied() {
  return FirebaseException(plugin: 'kahwa', code: 'permission-denied');
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    final isDenied =
        error is FirebaseException && error.code == 'permission-denied';

    return IllustratedMessage(
      asset: isDenied
          ? 'assets/undraw_access_denied.svg'
          : 'assets/undraw_void.svg',
      message: isDenied ? 'Access denied' : 'Error getting data',
      action: isDenied || onRetry == null
          ? null
          : OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}

/// A centered illustration with a short message below it.
class IllustratedMessage extends StatelessWidget {
  const IllustratedMessage({
    super.key,
    required this.asset,
    required this.message,
    this.action,
  });

  final String asset;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280, maxHeight: 240),
              child: SvgPicture.asset(asset),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
