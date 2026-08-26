import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/data/url_launch.dart';
import 'package:tasko/features/tasks/open_in_google_tasks_tile.dart';

void main() {
  testWidgets('opens the Google Tasks webViewLink', (tester) async {
    Uri? launched;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlLaunchProvider.overrideWithValue((uri) async {
            launched = uri;
            return true;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: OpenInGoogleTasksTile(
              webViewLink: 'https://tasks.google.com/task/abc',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.setTimeInGoogleTasks));
    await tester.pump();

    expect(launched, Uri.parse('https://tasks.google.com/task/abc'));
  });

  testWidgets('shows a snackbar when the link cannot be opened', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlLaunchProvider.overrideWithValue((uri) async => false),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: OpenInGoogleTasksTile(
              webViewLink: 'https://tasks.google.com/task/abc',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.setTimeInGoogleTasks));
    await tester.pump();

    expect(find.text(AppStrings.openLinkFailed), findsOneWidget);
  });
}
