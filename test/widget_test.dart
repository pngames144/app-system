import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('shows the app greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Привіт!'), findsOneWidget);
  });
}
