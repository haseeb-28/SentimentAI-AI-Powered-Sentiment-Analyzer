import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'state/sentiment_provider.dart';
import 'state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('analysis_history');
  runApp(const SentimentApp());
}

class SentimentApp extends StatelessWidget {
  const SentimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SentimentProvider(ApiService()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(AppConstants.primaryColor),
                brightness: Brightness.light,
                primary: const Color(AppConstants.primaryColor),
                secondary: const Color(AppConstants.secondaryColor),
                surface: Colors.white,
                error: const Color(AppConstants.errorColor),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFF1E293B),
                titleTextStyle: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(AppConstants.primaryColor),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(AppConstants.primaryColor),
                brightness: Brightness.dark,
                primary: const Color(AppConstants.primaryColor),
                secondary: const Color(AppConstants.secondaryColor),
                surface: const Color(0xFF1E293B),
                error: const Color(AppConstants.errorColor),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              cardColor: const Color(0xFF1E293B),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.shade700,
                    width: 1,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(AppConstants.primaryColor),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
