import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/plant_provider.dart';
import 'providers/dongeng_provider.dart';

class DongengApp extends StatefulWidget {
  const DongengApp({super.key});

  @override
  State<DongengApp> createState() => _DongengAppState();
}

class _DongengAppState extends State<DongengApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier(initial: ThemeMode.light);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _themeNotifier,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PlantProvider()),
          ChangeNotifierProvider(create: (_) => DongengProvider()),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: _themeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'Dongeng Anak Nusantara',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}