import 'package:flutter_test/flutter_test.dart';
import 'package:king_of_chicago/app.dart';

void main() {
  testWidgets('App renders title text', (WidgetTester tester) async {
    await tester.pumpWidget(const KingOfChicagoApp());
    expect(find.text('King of Chicago'), findsOneWidget);
  });
}
