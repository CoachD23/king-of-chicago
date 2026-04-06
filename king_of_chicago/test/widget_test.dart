import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_of_chicago/app.dart';

void main() {
  testWidgets('App renders loading screen with title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KingOfChicagoApp()),
    );
    expect(find.text('KING OF CHICAGO'), findsWidgets);
  });
}
