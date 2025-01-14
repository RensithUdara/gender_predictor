import 'package:flutter/material.dart';
import 'package:gender_predictor/screen/home_screen.dart';
import 'package:gender_predictor/screen/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme:
              themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const SplashScreen(), // Start with the SplashScreen
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
