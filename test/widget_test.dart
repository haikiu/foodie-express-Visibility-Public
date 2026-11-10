import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_express/main.dart';

void main() {
  testWidgets('Foodie Express app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodieExpressApp());

    expect(find.text('Foodie Express'), findsOneWidget);
  });
}