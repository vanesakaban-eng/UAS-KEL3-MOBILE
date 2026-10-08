import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/pages/expense_screen.dart';
import 'package:uku_app/pages/monthly_expense_screen.dart';
import 'package:uku_app/pages/transactions_screen.dart';

void main() {
  testWidgets('selects a category from the grid and saves the expense',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(body: ExpenseScreen(store: store)),
                  ),
                ),
                child: const Text('Buka Catat Pengeluaran'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Catat Pengeluaran'));
    await tester.pumpAndSettle();
    expect(find.text('Catat Pengeluaran'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsOneWidget);
    final shoppingCategory = find.widgetWithText(InkWell, 'Belanja');
    await tester.ensureVisible(shoppingCategory);
    await tester.tap(shoppingCategory);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '25000');
    await tester.tap(find.text('Tunai'));
    await tester.pump();
    expect(tester.widget<ChoiceChip>(find.byType(ChoiceChip).first).selected,
        isTrue);
    expect(find.text('Ringkasan Pengeluaran'), findsNothing);
    expect(find.text('Simpan'), findsOneWidget);
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(store.expenses.first.category, 'Belanja');
    expect(store.expenses.first.amount, 25000);
    expect(find.text('Buka Catat Pengeluaran'), findsOneWidget);
  });

  testWidgets('input mode selector moves the active orange segment',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpenseScreen(store: UkuStore())),
      ),
    );

    Text label(String text) => tester.widget<Text>(find.text(text));
    expect(label('Manual').style?.color, Colors.white);
    expect(label('Foto Bill').style?.color, const Color(0xFFFF8800));

    await tester.tap(find.text('Foto Bill'));
    await tester.pumpAndSettle();

    expect(label('Foto Bill').style?.color, Colors.white);
    expect(label('Manual').style?.color, const Color(0xFFFF8800));
  });

  testWidgets('Foto Bill category opens camera controls and continues',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpenseScreen(store: UkuStore())),
      ),
    );

    await tester.tap(find.text('Foto Bill'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Belanja'));
    await tester.pumpAndSettle();

    expect(find.text('Catat Pengeluaran foto bill'), findsOneWidget);
    expect(find.byTooltip('Pilih foto dari galeri'), findsOneWidget);
    expect(find.byTooltip('Ambil foto'), findsOneWidget);
    expect(find.byTooltip('Lanjutkan'), findsOneWidget);

    await tester.tap(find.byTooltip('Lanjutkan'));
    await tester.pumpAndSettle();
    expect(find.text('Jumlah'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);
  });

  testWidgets('choosing a category advances to expense details',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpenseScreen(store: UkuStore())),
      ),
    );

    expect(find.text('Pilih jenis pengeluaran'), findsOneWidget);
    expect(find.text('Jumlah'), findsNothing);
    final firstCategory = find.ancestor(
      of: find.text('Makanan & Minuman'),
      matching: find.byType(InkWell),
    );
    final categoryBox = find.descendant(
      of: firstCategory,
      matching: find.byType(Container),
    );
    expect(
      (tester.widget<Container>(categoryBox.first).decoration as BoxDecoration)
          .color,
      Colors.transparent,
    );
    await tester.tap(find.widgetWithText(InkWell, 'Belanja'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 190));

    final selectedCategory = find.ancestor(
      of: find.text('Belanja'),
      matching: find.byType(InkWell),
    );
    final selectedCategoryBox = find.descendant(
      of: selectedCategory,
      matching: find.byType(Container),
    );
    final selectedDecoration = tester
        .widget<Container>(selectedCategoryBox.first)
        .decoration as BoxDecoration;
    expect(selectedDecoration.color, const Color(0xFFF9C846));
    expect(
      (selectedDecoration.border as Border).top.color,
      const Color(0xFFFAAE36),
    );
    expect(find.text('Jumlah'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pilih jenis pengeluaran'), findsNothing);
    expect(find.text('Jumlah'), findsOneWidget);
    expect(find.text('Jenis Pengeluaran'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('Metode'), findsOneWidget);
    expect(find.text('Tunai'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('monthly expense screen only summarizes the current month',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore()..expenses.clear();
    final now = DateTime.now();
    store.addExpense(Expense(
      category: 'Makanan & Minuman',
      amount: 25000,
      date: now,
      location: '',
      purpose: '',
      method: 'Cash',
    ));
    store.addExpense(Expense(
      category: 'Belanja',
      amount: 90000,
      date: DateTime(now.year, now.month - 1, 12),
      location: '',
      purpose: '',
      method: 'Cash',
    ));

    var didGoBack = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonthlyExpenseScreen(
            store: store,
            onBack: () => didGoBack = true,
          ),
        ),
      ),
    );

    expect(find.text('Grafik Pengeluaran'), findsOneWidget);
    expect(find.text('Jenis Pengeluaran'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Rekap pengeluaran bulanan'), findsNothing);
    expect(find.text('Total Pengeluaran'), findsNothing);
    expect(find.text('1 transaksi'), findsOneWidget);
    expect(find.text('Rp 25.000'), findsOneWidget);
    expect(find.text('Simpan Pengeluaran'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    await tester.tap(find.byTooltip('Kembali'));
    expect(didGoBack, isTrue);
  });

  testWidgets('transactions card opens the stored expense details',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var didGoBack = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionsScreen(
            store: UkuStore(),
            onBack: () => didGoBack = true,
          ),
        ),
      ),
    );

    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Sabtu, 12 September 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    expect(didGoBack, isTrue);
    await tester.tap(find.text('Klik Untuk Detail Transaksi'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Transaksi'), findsOneWidget);
    expect(find.text('Pakaian'), findsOneWidget);
    expect(find.text('- Rp 200.000'), findsOneWidget);
  });
}
