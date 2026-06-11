import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/app_colors.dart';
import 'package:inotes/features/splash/presentation/pages/splash_page.dart';

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iNotes',
      theme: const CupertinoThemeData(brightness: Brightness.light, primaryColor: AppColors.accent),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      home: const SplashPage(),
    );
  }
}
