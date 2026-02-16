import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';
import 'providers/providers.dart';
import 'services/services.dart';
import 'ui/navigation/app_shell.dart';
import 'ui/theme/app_theme.dart';

/// Main entry point for Skill Forge.
///
/// Initializes the database, services, and providers before launching the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final dbHelper = DatabaseHelper();
  await dbHelper.initialize();

  final prefsService = PreferencesService();
  await prefsService.init();

  final ttsService = TtsService(prefsService);
  await ttsService.init();

  final exportImportService = ExportImportService(dbHelper);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // Navigation
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // Services
        Provider<PreferencesService>.value(value: prefsService),
        Provider<TtsService>.value(value: ttsService),
        Provider<ExportImportService>.value(value: exportImportService),

        // State providers
        ChangeNotifierProvider(create: (_) => GoalsProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => DecksProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => FlashcardsProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => StudyProvider(dbHelper)),
      ],
      child: const SkillForgeApp(),
    ),
  );
}

/// The root widget of Skill Forge.
///
/// Configures the MaterialApp with dark theme and navigation shell.
class SkillForgeApp extends StatelessWidget {
  const SkillForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Forge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
