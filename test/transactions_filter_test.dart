import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/expense/transactions_screen.dart';

void main() {
  testWidgets('filters transaction history by type and expense category',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = UkuStore();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TransactionsScreen(store: store)),
      ),
    );

    expect(find.text('Pemasukan bulanan'), findsOneWidget);
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.text('Pilih Filter'), findsOneWidget);
    expect(find.text('Atur Ulang'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);
    expect(
      tester.getCenter(find.byTooltip('Tutup filter')).dx,
      greaterThan(tester.getCenter(find.text('Pilih Filter')).dx),
    );
    expect(find.widgetWithText(ChoiceChip, 'Tabungan'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Pengeluaran'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Pemasukan'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Pengeluaran'));
    await tester.pumpAndSettle();
    final selectedTypeChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Pengeluaran'),
    );
    expect(selectedTypeChip.selectedColor, const Color(0xFFFF8800));
    expect(selectedTypeChip.labelStyle?.color, Colors.white);
    expect(find.widgetWithText(ChoiceChip, 'Hiburan'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Pendidikan'), findsOneWidget);
    final pakaianFilter = find.widgetWithText(ChoiceChip, 'Pakaian');
    await tester.ensureVisible(pakaianFilter);
    await tester.tap(pakaianFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Pakaian'), findsOneWidget);
    expect(find.text('Pemasukan bulanan'), findsNothing);
    expect(find.text('Jalan - jalan ke Bali'), findsNothing);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    final reopenedAllFilter = find.widgetWithText(ChoiceChip, 'Semua');
    await tester.ensureVisible(reopenedAllFilter);
    await tester.tap(reopenedAllFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Pakaian'), findsOneWidget);
    expect(find.text('Pemasukan bulanan'), findsNothing);
    expect(find.text('Jalan - jalan ke Bali'), findsNothing);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    final reopenedSavingFilter = find.widgetWithText(ChoiceChip, 'Tabungan');
    await tester.ensureVisible(reopenedSavingFilter);
    await tester.tap(reopenedSavingFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('Jenis tabungan'), findsOneWidget);
    final reopenedIncomeFilter = find.widgetWithText(ChoiceChip, 'Pemasukan');
    await tester.ensureVisible(reopenedIncomeFilter);
    await tester.tap(reopenedIncomeFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Pemasukan bulanan'), findsOneWidget);
    expect(find.text('Jalan - jalan ke Bali'), findsNothing);
    expect(find.text('Jenis tabungan'), findsNothing);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pemasukan'));
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Pemasukan bulanan'), findsOneWidget);
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);
    expect(find.text('Pakaian'), findsOneWidget);
  });

  testWidgets('offers every configured expense category', (tester) async {
    final store = UkuStore();
    store.addExpense(
      Expense(
        category: 'Transportasi',
        amount: 25000,
        date: DateTime.now(),
        location: '',
        purpose: '',
        method: 'Tunai',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TransactionsScreen(store: store)),
      ),
    );

    expect(find.byType(ChoiceChip), findsNothing);
    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pengeluaran'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'Pakaian'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Transportasi'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Belanja'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Hiburan'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Pendidikan'), findsOneWidget);

    final pendidikanFilter = find.widgetWithText(ChoiceChip, 'Pendidikan');
    await tester.ensureVisible(pendidikanFilter);
    await tester.tap(pendidikanFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada pengeluaran untuk kategori Pendidikan'),
      findsOneWidget,
    );
  });

  testWidgets('filters savings by saving category', (tester) async {
    final store = UkuStore();
    store.addSaving('Tabungan Pakaian', 500000, 'Pakaian', category: 'Pakaian');
    store.addSavingBalance(store.savings.last, 100000);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TransactionsScreen(store: store)),
      ),
    );
    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Tabungan'));
    await tester.pumpAndSettle();
    expect(find.text('Jenis tabungan'), findsOneWidget);

    final liburanFilter = find.widgetWithText(ChoiceChip, 'Liburan');
    await tester.ensureVisible(liburanFilter);
    await tester.tap(liburanFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Jalan - jalan ke Bali'), findsOneWidget);
    expect(find.text('Tabungan Pakaian'), findsNothing);
    expect(find.text('Pemasukan bulanan'), findsNothing);
  });
}
