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

    expect(find.text('Nama Tabungan'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Dana Liburan');
    await tester.enterText(find.byType(TextFormField).at(1), '2500000');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Dana untuk perjalanan',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Tabungan'));
    await tester.pumpAndSettle();

    expect(store.savings, hasLength(initialCount + 1));
    expect(store.savings.last.name, 'Dana Liburan');
    expect(store.savings.last.category, 'Liburan');
    expect(store.savings.last.target, 2500000);
    expect(store.savings.last.note, 'Dana untuk perjalanan');
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
    final addBalanceDialog = tester.widget<AlertDialog>(
      find.byType(AlertDialog),
    );
    expect(addBalanceDialog.backgroundColor, Colors.white);
    expect(addBalanceDialog.surfaceTintColor, Colors.white);
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Tambah'))
          .style
          ?.backgroundColor
          ?.resolve({}),
      const Color(0xFFFFAD2F),
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Batal'))
          .style
          ?.foregroundColor
          ?.resolve({}),
      const Color(0xFFFFAD2F),
    );
    await tester.enterText(find.byType(TextField), '500000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pumpAndSettle();

    expect(store.savings.first.current, 1500000);
    expect(store.income, 1500000);
    expect(find.text('Rp 1.500.000'), findsOneWidget);
    expect(
      store.activities.any((activity) =>
          activity.type == ActivityType.saving &&
          activity.title == 'Jalan - jalan ke Bali' &&
          activity.amount == 500000),
      isTrue,
    );
  });

  testWidgets('saving detail shows the entered note and compact summary',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = UkuStore();
    final saving = store.savings.first;
    var didGoBack = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SavingDetailScreen(
          store: store,
          saving: saving,
          onBack: () => didGoBack = true,
        ),
      ),
    );

    expect(find.text('Detail Tabungan'), findsOneWidget);
    expect(find.text('Nama Tabungan'), findsOneWidget);
    expect(find.text(saving.name), findsNWidgets(2));
    expect(find.text('Target Tabungan'), findsOneWidget);
    expect(find.text('3.000.000'), findsOneWidget);
    expect(find.text('Catatan'), findsNothing);
    expect(find.text(saving.note), findsNWidgets(2));
    expect(find.text('Jenis Tabungan'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ke Beranda'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Tambah saldo'), findsNothing);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Ke Beranda'));
    expect(didGoBack, isTrue);
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
    expect(find.text('Pilih jenis tabungan'), findsOneWidget);
    await tester.tap(find.text('Makanan & Minuman'));
    await tester.pumpAndSettle();
    expect(find.text('Nama Tabungan'), findsOneWidget);
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
    expect(find.text(saving.name), findsNWidgets(2));
    expect(find.text('3.000.000'), findsOneWidget);
    expect(find.text('Jenis Tabungan'), findsOneWidget);
  });

  testWidgets('Home features the newest saving while Nabung keeps old savings',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore()
      ..addSaving(
        'Tabungan Baru',
        2500000,
        'Rencana baru',
        category: 'Liburan',
      );
    var selectedSavingName = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(
            store: store,
            onExpense: () {},
            onSavingTarget: (saving) => selectedSavingName = saving.name,
          ),
        ),
      ),
    );

    expect(find.text('Tabungan Baru'), findsOneWidget);
    expect(find.text('Jalan - jalan ke Bali'), findsNothing);
    await tester.ensureVisible(find.text('Tabungan Baru'));
    await tester.tap(find.text('Tabungan Baru'));
    expect(selectedSavingName, 'Tabungan Baru');

    await tester.pumpWidget(
      MaterialApp(home: SavingScreen(store: store)),
    );
    expect(find.text('Tabungan Baru'), findsOneWidget);
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);
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

  testWidgets('shows remaining budget as a non-interactive value',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(
            store: store,
            onExpense: () {},
          ),
        ),
      ),
    );
    final budgetLabel = find.text('Sisa Budget');
    expect(budgetLabel, findsOneWidget);
    expect(
      find.ancestor(
        of: budgetLabel,
        matching: find.byWidgetPredicate(
          (widget) => widget is AbsorbPointer && widget.absorbing,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: budgetLabel, matching: find.byType(InkWell)),
      findsNothing,
    );
    await tester.tap(budgetLabel, warnIfMissed: false);
    expect(find.text('Sisa Budget'), findsOneWidget);
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
    expect(find.text('Budget bulan ini'), findsOneWidget);
    expect(find.text('Buat Budget'), findsNothing);
    expect(find.text('Edit Budget Bulan Ini'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '1.500.000');
    await tester.enterText(find.byType(TextField), '2000000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
    await tester.pumpAndSettle();

    expect(store.budget, 2000000);
    expect(find.text(rupiah(store.budget).replaceFirst('Rp ', '')),
        findsOneWidget);
    expect(find.text('Edit Budget Bulan Ini'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Buat Budget'), findsNothing);
  });

  testWidgets('sets the monthly budget through the same edit action',
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
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Buat Budget'), findsNothing);
    expect(find.text('Edit Budget Bulan Ini'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(store.remainingBudget, 0);
    await tester.enterText(find.byType(TextField), '2500000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
    await tester.pumpAndSettle();

    expect(store.hasBudgetForMonth(DateTime.now()), isTrue);
    expect(store.budget, 2500000);
    expect(find.text(rupiah(store.budget).replaceFirst('Rp ', '')),
        findsOneWidget);
    expect(find.text('Buat Budget'), findsNothing);
  });
}
