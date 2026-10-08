import 'package:flutter/foundation.dart';

class Expense {
  Expense({
    required this.category,
    required this.amount,
    required this.date,
    required this.location,
    required this.purpose,
    required this.method,
  });

  final String category;
  final double amount;
  final DateTime date;
  final String location;
  final String purpose;
  final String method;
}

class Saving {
  Saving({
    required this.name,
    required this.target,
    required this.current,
    required this.note,
    this.category = 'Lainnya',
  });

  final String name;
  final double target;
  double current;
  final String note;
  final String category;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);
}

class UkuStore extends ChangeNotifier {
  double budget = 1500000;
  final double income = 1000000;

  final List<Expense> expenses = [
    Expense(category: 'Pakaian', amount: 200000, date: DateTime(2026, 9, 12), location: 'Mall', purpose: 'Kebutuhan', method: 'Cash'),
  ];

  final List<Saving> savings = [
    Saving(name: 'Jalan - jalan ke Bali', target: 3000000, current: 1000000, note: 'Liburan', category: 'Liburan'),
  ];

  double get totalExpense => expenses.fold(0, (sum, item) => sum + item.amount);
  double get remainingBudget => budget - totalExpense;

  void addExpense(Expense expense) {
    expenses.insert(0, expense);
    notifyListeners();
  }

  void setBudget(double value) {
    budget = value;
    notifyListeners();
  }

  void addSaving(String name, double target, String note, {String category = 'Lainnya'}) {
    savings.add(Saving(name: name, target: target, current: 0, note: note, category: category));
    notifyListeners();
  }

  void addSavingBalance(Saving saving, double amount) {
    saving.current += amount;
    notifyListeners();
  }

  List<Expense> expensesForMonth(DateTime month) {
    return expenses.where((e) => e.date.year == month.year && e.date.month == month.month).toList();
  }

  Map<String, double> categoryTotals([DateTime? month]) {
    final source = month == null ? expenses : expensesForMonth(month);
    final result = <String, double>{};
    for (final e in source) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }
}

String rupiah(num value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write('.');
    buffer.write(text[i]);
  }
  return 'Rp ${buffer.toString()}';
}
