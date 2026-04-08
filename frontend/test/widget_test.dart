import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya_sathi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AarogyaSathiApp());
    expect(find.text('Aarogya Sathi'), findsOneWidget);
  });
}
