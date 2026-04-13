import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier({ThemeMode initial = ThemeMode.system}) : super(initial);

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    value = mode;
  }
}

class ThemeProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeProvider({
    super.key,
    required ThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeNotifier of(BuildContext context) {
    final provider =
    context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'ThemeProvider tidak ditemukan!');
    return provider!.notifier!;
  }
}