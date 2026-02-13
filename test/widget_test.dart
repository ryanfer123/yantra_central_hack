import 'package:flutter_test/flutter_test.dart';
import 'package:ev_guardian/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EvGuardianApp());
    await tester.pump();
    expect(find.text('EV Guardian'), findsOneWidget);
  });
}
