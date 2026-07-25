import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/app.dart';

void main() {
  testWidgets('TaskoApp builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskoApp()));
    await tester.pump();
    expect(find.text('Tasko'), findsWidgets);
  });
}
