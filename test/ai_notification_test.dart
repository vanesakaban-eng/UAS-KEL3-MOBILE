import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/home/home_screen.dart';

void main() {
  testWidgets('AI notification summarizes current-month spending and budget',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final store = UkuStore()
      ..expenses.clear()
      ..setBudget(1500000)
      ..addExpense(Expense(
        category: 'Belanja',
        amount: 1450000,
        date: now,
        location: '',
        purpose: '',
        method: 'Tunai',
      ))
      ..addExpense(Expense(
        category: 'Belanja',
        amount: 9000000,
        date: DateTime(now.year, now.month - 1, 15),
        location: '',
        purpose: '',
        method: 'Tunai',
      ));

    var openedAnalysis = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(
            store: store,
            onExpense: () {},
            onExpenseDetails: () => openedAnalysis = true,
          ),
        ),
      ),
    );

    expect(find.text('AI Financial Assistant'), findsOneWidget);
    expect(find.text('Budget Warning'), findsNothing);
    expect(find.text('Pengeluaranmu hampir melewati batas!'), findsOneWidget);
    expect(find.text('Rp 1.450.000'), findsOneWidget);
    expect(find.text('96.7% terpakai'), findsOneWidget);
    expect(
      find.textContaining('Dengan sisa budget Rp 50.000'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Lihat Analisis Keuangan'));
    await tester.tap(find.text('Lihat Analisis Keuangan'));
    expect(openedAnalysis, isTrue);
  });
}
