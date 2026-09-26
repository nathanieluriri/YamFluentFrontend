import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/ui/widgets/modals/search_picker_sheet.dart';

void main() {
  testWidgets('the language picker can be searched and picked from', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => picked = await SearchPickerSheet.show(
                context,
                items: const ['English (English)', 'Yoruba (Yorùbá)'],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'yor');
    await tester.pumpAndSettle();
    expect(find.text('English (English)'), findsNothing);
    await tester.tap(find.text('Yoruba (Yorùbá)'));
    await tester.pumpAndSettle();
    expect(picked, 'Yoruba (Yorùbá)');
    expect(find.byType(TextField), findsNothing);
  });
}
