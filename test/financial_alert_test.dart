import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/navigation/main_navigation.dart';

void main() {
  testWidgets('restored over-budget state shows warning on app open',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await UkuStore.loadPersisted();
    final now = DateTime.now();
    store
      ..setBudget(100000)
      ..addExpense(Expense(
        category: 'Belanja',
        amount: 150000,
        date: now,
        location: '',
        purpose: '',
        method: 'Tunai',
      ));
    await store.persistFinancialData();

    final restoredStore = await UkuStore.loadPersisted();
    expect(restoredStore.remainingBudget, -50000);

    await tester.pumpWidget(
      MaterialApp(home: MainNavigationScreen(store: restoredStore)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kondisi keuangan buruk'), findsOneWidget);
    expect(find.textContaining('Rp 50.000'), findsOneWidget);
    final warningDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(warningDialog.backgroundColor, Colors.white);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded)).color,
      const Color(0xFFFAAE36),
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Mengerti'))
          .style
          ?.foregroundColor
          ?.resolve({}),
      const Color(0xFFFAAE36),
    );
  });
}
