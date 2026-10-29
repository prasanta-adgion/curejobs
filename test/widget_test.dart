import 'package:flutter_test/flutter_test.dart';

import 'package:curejobs/main.dart';

void main() {
  testWidgets('Splash shows brand and moves to home', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Verified employers'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
