import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/core/theme.dart';

class KahwaApp extends StatefulWidget {
  const KahwaApp({super.key});

  @override
  State<KahwaApp> createState() => _KahwaAppState();
}

class _KahwaAppState extends State<KahwaApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'kahwa',
      theme: appTheme(),
      routerConfig: _router,
    );
  }
}
