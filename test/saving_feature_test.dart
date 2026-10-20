import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/budget/budget_screen.dart';
import 'package:uku_app/features/home/home_screen.dart';
import 'package:uku_app/features/savings/saving_creation_screen.dart';
import 'package:uku_app/features/savings/saving_detail_screen.dart';
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
    expect(
      store.activities.any((activity) =>
          activity.type == ActivityType.saving &&
          activity.title == 'Jalan - jalan ke Bali' &&
          activity.amount == 500000),
      isTrue,
    );
  });

  testWidgets('detail footer uses the saving action style and adds balance',
      (tester) async {
    final store = UkuStore();
    final saving = store.savings.first;

    await tester.pumpWidget(
      MaterialApp(
        home: SavingDetailScreen(store: store, saving: saving),
      ),
    );

    final addBalanceButton = find.widgetWithText(TextButton, 'Tambah saldo');
    expect(addBalanceButton, findsOneWidget);
    await tester.tap(addBalanceButton);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '250000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(saving.current, 1250000);
    expect(store.activities.first.amount, 250000);
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
    final savingButton = find.text('Nabung').first;
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

  testWidgets('tapping the Home saving target opens its detail page',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore();
    final saving = store.savings.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(store: store, onExpense: () {}),
        ),
      ),
    );

    final savingTarget = find.text(saving.name);
    await tester.ensureVisible(savingTarget);
    await tester.tap(savingTarget);
    await tester.pumpAndSettle();

    expect(find.byType(SavingDetailScreen), findsOneWidget);
    expect(find.text('Detail Tabungan'), findsOneWidget);
  });

  testWidgets('tapping a saving target opens its detail page', (tester) async {
    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(home: SavingScreen(store: store)),
    );

    await tester.tap(find.text('Jalan - jalan ke Bali'));
    await tester.pumpAndSettle();

    expect(find.byType(SavingDetailScreen), findsOneWidget);
    expect(find.text('Detail Tabungan'), findsOneWidget);
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

  testWidgets('opens the monthly budget editor and saves the budget',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: BudgetScreen(store: store))),
    );
    expect(find.text('Buat Budget'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Selesai'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Budget bulan ini'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Budget Bulan Ini'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '2000000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
    await tester.pumpAndSettle();

    expect(store.budget, 2000000);
    expect(find.text('2.000.000'), findsOneWidget);
    expect(find.text('Edit Budget Bulan Ini'), findsNothing);
    expect(find.text('Buat Budget'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('allows creating a budget after the month changes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore()
      ..budgetMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: BudgetScreen(store: store))),
    );
    expect(find.text('Buat Budget bulan ini'), findsOneWidget);
    expect(find.text('Buat Budget'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    await tester.tap(find.text('Buat Budget bulan ini'));
    await tester.pumpAndSettle();
    expect(find.text('Buat Budget Bulan Ini'), findsOneWidget);
    expect(find.text('Edit Budget Bulan Ini'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(store.remainingBudget, 0);
  });
}
