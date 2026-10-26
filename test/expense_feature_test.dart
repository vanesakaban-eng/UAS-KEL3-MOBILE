import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/expense/expense_screen.dart';
import 'package:uku_app/features/expense/monthly_expense_screen.dart';
import 'package:uku_app/features/expense/recap_screen.dart';
import 'package:uku_app/features/expense/transactions_screen.dart';
import 'package:uku_app/features/home/home_screen.dart';
import 'package:uku_app/navigation/main_navigation.dart';

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

  testWidgets('transactions screen shows stored expense details directly',
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
    expect(find.text('Detail Transaksi'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Pakaian'),
      ),
      findsOneWidget,
    );
    expect(find.text('Metode: Cash'), findsOneWidget);
    expect(find.text('- Rp 200.000'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    expect(didGoBack, isTrue);
  });

  testWidgets(
      'transaction history uses category icons for expenses and savings',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore();
    store.addExpense(Expense(
      category: 'Makanan & Minuman',
      amount: 25000,
      date: DateTime.now(),
      location: '',
      purpose: '',
      method: 'Tunai',
    ));
    store.addSavingBalance(store.savings.first, 100000);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TransactionsScreen(store: store)),
      ),
    );

    Finder findAsset(String path) => find.byWidgetPredicate((widget) {
          if (widget is! Image) return false;
          final image = widget.image;
          return image is AssetImage && image.assetName == path;
        });

    expect(findAsset('assets/icons/Restaurant.png'), findsOneWidget);
    expect(findAsset('assets/icons/Airplane Landing.png'), findsWidgets);
    expect(findAsset('assets/icons/Clothes.png'), findsOneWidget);
  });

  testWidgets('recap history includes expenses, income and saving activity',
      (tester) async {
    final store = UkuStore();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RecapScreen(store: store))),
    );

    expect(find.text('Riwayat Pengeluaran'), findsOneWidget);
    expect(find.text('Pakaian'), findsOneWidget);
    expect(find.text('Pemasukan bulanan'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);
    expect(find.text('3 aktivitas'), findsOneWidget);
  });

  testWidgets('recap shows history for the current selected month',
      (tester) async {
    final store = UkuStore()..expenses.clear();
    final now = DateTime.now();
    store.addExpense(Expense(
      category: 'Makan Bulan Ini',
      amount: 45000,
      date: now,
      location: '',
      purpose: '',
      method: 'Cash',
    ));
    store.addExpense(Expense(
      category: 'Belanja Bulan Lalu',
      amount: 90000,
      date: DateTime(now.year, now.month - 1, 12),
      location: '',
      purpose: '',
      method: 'Cash',
    ));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RecapScreen(store: store))),
    );

    expect(find.text('Rekap Aktivitas'), findsOneWidget);
    expect(find.text('Pilih Bulan & Tahun'), findsOneWidget);
    expect(find.text('Grafik Pengeluaran'), findsOneWidget);
    expect(find.text('Riwayat Pengeluaran'), findsOneWidget);
    expect(find.text('Makan Bulan Ini'), findsOneWidget);
    expect(find.text('- Rp 45.000'), findsOneWidget);
    expect(find.text('Belanja Bulan Lalu'), findsNothing);
  });

  testWidgets('home opens recap without hiding bottom navigation',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    await tester.tap(find.text('Rekap Aktivitas'));
    await tester.pumpAndSettle();

    expect(find.text('September, 2026'), findsWidgets);
    expect(find.text('Pakaian'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Grafik Pengeluaran'), findsNothing);
  });

  testWidgets('recap month picker selects only a month and year',
      (tester) async {
    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RecapScreen(store: store))),
    );

    await tester.tap(find.text('September, 2026').first);
    await tester.pumpAndSettle();

    expect(find.text('Pilih Bulan & Tahun'), findsNWidgets(2));
    expect(find.text('2026'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(find.text('Oktober'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Oktober'));
    await tester.pumpAndSettle();

    expect(find.text('Oktober, 2026'), findsWidgets);
    expect(find.text('Jalan - jalan ke Bali'), findsNothing);
  });

  testWidgets('AI notification details opens the expense feature',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    expect(find.text('Grafik Keuangan'), findsOneWidget);
    expect(find.text('Kondisi keuangan saat ini'), findsOneWidget);
    final detailsButton = find.text('Klik Untuk Detail Transaksi');
    await tester.ensureVisible(detailsButton);
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();

    expect(find.text('Grafik Pengeluaran'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsWidgets);
  });

  testWidgets('shows a warning on app open when monthly budget is exceeded',
      (tester) async {
    final now = DateTime.now();
    final store = UkuStore()..setBudget(100000);
    store.addExpense(Expense(
      category: 'Belanja',
      amount: 150000,
      date: now,
      location: '',
      purpose: '',
      method: 'Tunai',
    ));

    await tester.pumpWidget(
      MaterialApp(home: MainNavigationScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kondisi keuangan buruk'), findsOneWidget);
    expect(find.textContaining('Rp 50.000'), findsOneWidget);

    await tester.tap(find.text('Lihat budget'));
    await tester.pumpAndSettle();
    expect(find.text('Budget'), findsWidgets);
    expect(find.text('Kondisi keuangan buruk'), findsNothing);
  });

  testWidgets('does not show an over-budget warning within monthly budget',
      (tester) async {
    final now = DateTime.now();
    final store = UkuStore()..setBudget(200000);
    store.addExpense(Expense(
      category: 'Belanja',
      amount: 150000,
      date: now,
      location: '',
      purpose: '',
      method: 'Tunai',
    ));

    await tester.pumpWidget(
      MaterialApp(home: MainNavigationScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kondisi keuangan buruk'), findsNothing);
  });

  testWidgets('AI finance chart plots actual expenses for the current month',
      (tester) async {
    final now = DateTime.now();
    final store = UkuStore()..expenses.clear();
    store.setBudget(100000);
    store.addExpense(Expense(
      category: 'Bulan ini',
      amount: 25000,
      date: now,
      location: '',
      purpose: '',
      method: 'Tunai',
    ));
    store.addExpense(Expense(
      category: 'Bulan lalu',
      amount: 70000,
      date: DateTime(now.year, now.month - 1, 1),
      location: '',
      purpose: '',
      method: 'Tunai',
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreenContent(store: store, onExpense: () {}),
        ),
      ),
    );

    final chart = tester.widget<BarChart>(find.byType(BarChart).first);
    expect(chart.data.barGroups[0].barRods.single.toY, 25000);
    expect(chart.data.barGroups[1].barRods.single.toY, 75000);
  });

  testWidgets('home transaction card opens the Transactions navigation page',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    final pakaianExpense = find.text('Pakaian');
    await tester.ensureVisible(pakaianExpense);
    await tester.tap(pakaianExpense);
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Metode: Cash'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, User'), findsOneWidget);
  });

  testWidgets('home saving target detail keeps the main navigation visible',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    final savingTarget = find.text('Jalan - jalan ke Bali');
    await tester.ensureVisible(savingTarget);
    await tester.tap(savingTarget);
    await tester.pumpAndSettle();

    expect(find.text('Detail Tabungan'), findsOneWidget);
    expect(find.text('Jenis Tabungan'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
  });

  testWidgets('newly recorded expense appears with the seeded history',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );

    await tester.tap(find.text('Catat Pengeluaran'));
    await tester.pumpAndSettle();
    final shoppingCategory = find.widgetWithText(InkWell, 'Belanja');
    await tester.ensureVisible(shoppingCategory);
    await tester.tap(shoppingCategory);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '25000');
    await tester.tap(find.text('Tunai'));
    await tester.pump();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transaksi').last);
    await tester.pumpAndSettle();
    expect(find.text('Metode: Cash'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Pakaian'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Belanja'),
      ),
      findsOneWidget,
    );
    expect(find.text('- Rp 200.000'), findsOneWidget);
    expect(find.text('- Rp 25.000'), findsOneWidget);
    expect(find.text('Detail Transaksi'), findsNothing);
  });
}
