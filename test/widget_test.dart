import 'package:flutter_test/flutter_test.dart';
import 'package:my_perpus/main.dart';

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyPerpusApp());
    expect(find.byType(MyPerpusApp), findsOneWidget);
  });
}
