import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/budget/budget_screen.dart';
import 'package:uku_app/features/home/home_screen.dart';
import 'package:uku_app/features/savings/saving_creation_screen.dart';
import 'package:uku_app/features/savings/saving_screen.dart';

void main() {
  testWidgets('creates a saving after selecting a category', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore();
    final initialCount = store.savings.length;

    await tester.pumpWidget(
      MaterialApp(home: SavingCreationScreen(store: store)),
    );
    await tester.tap(find.text('Liburan'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Tabungan'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Dana Liburan');
    await tester.enterText(find.byType(TextFormField).at(1), '2500000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Tabungan'));
    await tester.pumpAndSettle();

    expect(store.savings, hasLength(initialCount + 1));
    expect(store.savings.last.name, 'Dana Liburan');
    expect(store.savings.last.category, 'Liburan');
    expect(store.savings.last.target, 2500000);
  });

  testWidgets('refreshes the saving balance after adding a deposit',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore();

    await tester.pumpWidget(MaterialApp(home: SavingScreen(store: store)));
    await tester.ensureVisible(find.text('Tambah saldo'));
    await tester.tap(find.text('Tambah saldo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '500000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(store.savings.first.current, 1500000);
    expect(find.text('Rp 1.500.000'), findsOneWidget);
  });

  testWidgets('opens saving creation from the Home Nabung button',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(store: UkuStore(), onExpense: () {}),
        ),
      ),
    );
    final savingButton = find.widgetWithText(InkWell, 'Nabung');
    await tester.ensureVisible(savingButton);
    await tester.tap(savingButton);
    await tester.pumpAndSettle();

    expect(find.text('Target Tabungan'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Buat Tabungan'), findsOneWidget);
    await tester.tap(find.text('Makanan & Minuman'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Tabungan'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsOneWidget);
  });

  testWidgets('opens Budget when tapping the remaining budget box',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var openedBudget = false;
    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(
            store: store,
            onExpense: () {},
            onBudget: () => openedBudget = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text(rupiah(store.remainingBudget)));

    expect(openedBudget, isTrue);
  });

  testWidgets('saves the monthly budget from the inline form', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: BudgetScreen(store: store))),
    );
    await tester.enterText(find.byType(TextField), '2000000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
    await tester.pumpAndSettle();

    expect(store.budget, 2000000);
    expect(find.text('2.000.000'), findsOneWidget);
  });
}
