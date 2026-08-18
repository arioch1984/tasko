import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/app.dart';
import 'package:tasko/core/monday_material_localizations.dart';
import 'package:tasko/core/theme_preference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TaskoApp uses Monday as the first day of the week',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const TaskoApp(),
      ),
    );
    await tester.pump();

    final l10n = MaterialLocalizations.of(
      tester.element(find.byType(Scaffold)),
    );
    expect(l10n.firstDayOfWeekIndex, 1);
    expect(l10n.narrowWeekdays[l10n.firstDayOfWeekIndex], 'M');
  });

  testWidgets('calendar weekday row is Mon–Sun', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          MondayMaterialLocalizations.delegate,
        ],
        home: Scaffold(
          body: CalendarDatePicker(
            initialDate: DateTime(2026, 8, 19),
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            onDateChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final letters = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .where((value) => value.length == 1)
        .take(7)
        .toList();

    expect(letters, ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
  });
}
