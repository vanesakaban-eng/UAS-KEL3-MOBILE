import 'package:flutter_test/flutter_test.dart';
import 'package:uku_app/features/expense/receipt_text_parser.dart';

void main() {
  test('prefers the bill total over subtotal, cash, and change', () {
    final result = parseReceiptText('''
TOKO MAKMUR
Tanggal: 05/11/2026
Subtotal Rp 48.000
TOTAL BELANJA Rp 43.000
Tunai Rp 50.000
Kembali Rp 7.000
''');

    expect(result.amount, 43000);
    expect(result.date, DateTime(2026, 11, 5));
    expect(result.merchant, 'TOKO MAKMUR');
  });

  test('reads ISO date and decimal-formatted amount', () {
    final result = parseReceiptText('''
MINIMARKET
2026-11-05
Grand Total Rp 12.500,00
''');

    expect(result.amount, 12500);
    expect(result.date, DateTime(2026, 11, 5));
    expect(result.merchant, 'MINIMARKET');
  });

  test('does not invent values when a bill has no readable amount or date', () {
    final result = parseReceiptText('TOKO MAKMUR\nTerima kasih');

    expect(result.amount, isNull);
    expect(result.date, isNull);
    expect(result.merchant, 'TOKO MAKMUR');
  });
}
