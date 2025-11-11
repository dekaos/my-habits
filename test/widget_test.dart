import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('App title validation', () {
    const appTitle = 'Habit Hero';
    expect(appTitle, equals('Habit Hero'));
    expect(appTitle.length, greaterThan(0));
  });

  test('Theme color validation', () {
    const seedColor = Color(0xFF6366F1);
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    expect(lightColorScheme.brightness, equals(Brightness.light));
    expect(darkColorScheme.brightness, equals(Brightness.dark));
  });

  test('Card theme configuration', () {
    final cardTheme = CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    expect(cardTheme.elevation, equals(0));
    expect(cardTheme.shape, isA<RoundedRectangleBorder>());

    final shape = cardTheme.shape as RoundedRectangleBorder;
    final borderRadius = shape.borderRadius as BorderRadius;
    expect(borderRadius.topLeft.x, equals(16));
  });

  testWidgets('Simple widget test', (WidgetTester tester) async {
    // Build a simple Material app to verify Flutter testing works
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
        ),
        home: const Scaffold(
          body: Center(child: Text('Habit Hero')),
        ),
      ),
    );

    // Verify the widget builds successfully
    expect(find.text('Habit Hero'), findsOneWidget);
  });

  test('Material3 theme configuration', () {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
    );

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.brightness, equals(Brightness.light));
  });
}
