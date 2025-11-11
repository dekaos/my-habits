import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupPerformanceMonitoring();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vbsmpgkxebxjehsxedjk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZic21wZ2t4ZWJ4amVoc3hlZGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNDgzOTMsImV4cCI6MjA3NjYyNDM5M30.gF18J-QkV6sF57rpEoAl5-bLSniaFK3DFXywoZecVbo', // Replace with your Supabase anon key
  );

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize notification service: $e');
  }

  await Future.wait([
    _warmupShaders(),
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

void _setupPerformanceMonitoring() {
  if (!SchedulerBinding.instance.schedulerPhase.name.contains('idle')) {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final totalSpan = timing.totalSpan.inMilliseconds;

        const frameDropThreshold = 20; // ms

        if (totalSpan > frameDropThreshold) {
          debugPrint(
              '⚠️ PERFORMANCE: Frame drop detected! ${totalSpan}ms (target: 16ms)');
          debugPrint('   Build: ${timing.buildDuration.inMilliseconds}ms');
          debugPrint('   Raster: ${timing.rasterDuration.inMilliseconds}ms');
        }
      }
    });

    debugPrint('🔍 Performance monitoring enabled');
  }
}

Future<void> _warmupShaders() async {
  return Future.delayed(Duration.zero);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Hero',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('pt'), // Portuguese
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
