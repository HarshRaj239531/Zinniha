import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App launches and renders Bookshelf', (WidgetTester tester) async {
    await tester.pumpWidget(const ZinnihaApp());
    await tester.pumpAndSettle();

    expect(find.text('Zinnia Studio'), findsOneWidget);
    expect(find.text('FREE & UNLOCKED'), findsOneWidget);
  });
}
