import 'package:app/router/app_router.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MeuAppSimulados());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MeuAppSimulados extends StatelessWidget {
  const MeuAppSimulados({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Koin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.roteador,
      scrollBehavior: AppScrollBehavior(),
    );
  }
}