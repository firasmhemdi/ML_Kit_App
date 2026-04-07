import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/home_page.dart';
import 'pages/ocr_page.dart';
import 'pages/face_page.dart';
import 'pages/translate_page.dart';
import 'pages/ai_page.dart';
import 'theme/app_theme.dart';

void main() async {
  // ✅ ajouter "async" ici
  WidgetsFlutterBinding.ensureInitialized(); // ✅ obligatoire
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = {
    '/home': (context) => HomePage(),
    '/ocr': (context) => OcrPage(),
    '/face': (context) => FacePage(),
    '/translate': (context) => TranslatePage(),
    '/ai': (context) => AiPage(),
  };

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: routes,
      home: HomePage(),
    );
  }
}
