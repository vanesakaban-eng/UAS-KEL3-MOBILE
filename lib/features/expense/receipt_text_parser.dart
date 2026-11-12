class ReceiptTextResult {
  const ReceiptTextResult({this.amount, this.date, this.merchant});

  final double? amount;
  final DateTime? date;
  final String? merchant;
}

ReceiptTextResult parseReceiptText(String text) {
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  final preferredAmounts = <(int, double)>[];
  final fallbackAmounts = <double>[];
  for (final line in lines) {
    final normalized = line.toLowerCase();
    final isExcludedTotal = RegExp(
      r'\b(total|jumlah)\s*(item|barang|diskon|kembali)\b',
    ).hasMatch(normalized);
    final isPreferredTotal = !isExcludedTotal &&
        RegExp(
          r'\b(grand\s*total|net\s*total|amount\s*due|payable|'
          r'total(?:\s*(?:belanja|pembayaran|tagihan))?|'
          r'jumlah(?:\s*(?:tagihan|bayar))?)\b',
        ).hasMatch(normalized);
    final hasCurrency = RegExp(r'\b(rp|idr)\b').hasMatch(normalized);

    for (final match in RegExp(r'\d[\d.,]*').allMatches(line)) {
      final amount = _parseAmount(match.group(0)!);
      if (amount == null) continue;
      if (isPreferredTotal) {
        final priority = normalized.contains('grand') ||
                normalized.contains('amount due') ||
                normalized.contains('payable') ||
                normalized.contains('net total')
            ? 2
            : 1;
        preferredAmounts.add((priority, amount));
      } else if (hasCurrency && !isExcludedTotal) {
        fallbackAmounts.add(amount);
      }
    }
  }

  final amount = preferredAmounts.isNotEmpty
      ? preferredAmounts.reduce((a, b) => a.$1 >= b.$1 ? a : b).$2
      : fallbackAmounts.isEmpty
          ? null
          : fallbackAmounts.reduce((a, b) => a >= b ? a : b);
  final date = _parseDate(text);
  final merchant = _parseMerchant(lines);

  return ReceiptTextResult(amount: amount, date: date, merchant: merchant);
}

double? _parseAmount(String value) {
  final withoutDecimal = value.replaceFirst(RegExp(r'[.,]\d{2}$'), '');
  final digits = withoutDecimal.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 3) return null;
  final amount = double.tryParse(digits);
  return amount != null && amount > 0 ? amount : null;
}

DateTime? _parseDate(String text) {
  final isoDate = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b').firstMatch(text);
  if (isoDate != null) {
    return _validDate(
      int.parse(isoDate.group(1)!),
      int.parse(isoDate.group(2)!),
      int.parse(isoDate.group(3)!),
    );
  }

  final localDate =
      RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})\b').firstMatch(text);
  if (localDate == null) return null;

  final day = int.parse(localDate.group(1)!);
  final month = int.parse(localDate.group(2)!);
  var year = int.parse(localDate.group(3)!);
  if (year < 100) year += 2000;
  return _validDate(year, month, day);
}

DateTime? _validDate(int year, int month, int day) {
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

String? _parseMerchant(List<String> lines) {
  final excludedTerms = RegExp(
    r'\b(total|subtotal|jumlah|tanggal|date|invoice|struk|receipt|'
    r'cash|tunai|kembali|change|diskon|discount|pajak|tax|'
    r'kasir|cashier|no\.?)\b',
    caseSensitive: false,
  );
  for (final line in lines) {
    if (!RegExp(r'[a-zA-Z]').hasMatch(line) ||
        excludedTerms.hasMatch(line) ||
        _parseDate(line) != null) {
      continue;
    }
    return line;
  }
  return null;
}
