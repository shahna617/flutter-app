import 'package:flutter_test/flutter_test.dart';
import 'package:guardly_app/main.dart';

void main() {
  testWidgets('RoleGate and navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify DevRolePickerScreen is presented initially.
    expect(find.text('Development Role Selector'), findsOneWidget);
    expect(find.text('Continue as Student'), findsOneWidget);
    expect(find.text('Continue as Admin'), findsOneWidget);

    // Tap 'Continue as Student' and pump frames.
    await tester.tap(find.text('Continue as Student'));
    await tester.pumpAndSettle();

    // Verify StudentShell is displayed.
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('My reports'), findsOneWidget);
    expect(find.text('Student home tab placeholder. Real screen content will be placed here by team members.'), findsOneWidget);

    // Tap temporary logout in StudentShell.
    await tester.tap(find.text('Log out (Temporary)').first);
    await tester.pumpAndSettle();

    // Verify we are back on DevRolePickerScreen.
    expect(find.text('Development Role Selector'), findsOneWidget);

    // Tap 'Continue as Admin' and pump frames.
    await tester.tap(find.text('Continue as Admin'));
    await tester.pumpAndSettle();

    // Verify AdminShell is displayed.
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Admin overview tab placeholder. Real screen content will be placed here by team members.'), findsOneWidget);

    // Switch to Queue tab.
    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();
    expect(find.text('Admin report review queue placeholder.'), findsOneWidget);
  });
}
