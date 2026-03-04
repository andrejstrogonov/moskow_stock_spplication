import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moskow_stock_spplication/main.dart';

void main() {
  testWidgets('Smoke test: navigation to deposit and loan screens', (WidgetTester tester) async {
    await tester.pumpWidget(const MoskowStockApp());

    // Wait for home screen
    await tester.pumpAndSettle();

    // Tap on 'Вклад' button (label)
    expect(find.text('Вклад'), findsWidgets);
    await tester.tap(find.text('Вклад').first);
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор вкладов'), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on 'Кредит'
    expect(find.text('Кредит'), findsWidgets);
    await tester.tap(find.text('Кредит').first);
    await tester.pumpAndSettle();

    expect(find.text('Кредитный калькулятор'), findsOneWidget);
  });
}

