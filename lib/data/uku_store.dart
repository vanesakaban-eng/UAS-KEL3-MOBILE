import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uku_app/data/category_icons.dart';
import 'package:uku_app/data/mobile_api.dart';

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

enum ActivityType { expense, income, saving }

class FinancialActivity {
  const FinancialActivity({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.description = '',
    this.location = '',
    this.method = '',
    this.iconPath,
    this.category,
  });

  final ActivityType type;
  final String title;
  final double amount;
  final DateTime date;
  final String description;
  final String location;
  final String method;
  final String? iconPath;
  final String? category;

  String get typeLabel => switch (type) {
        ActivityType.expense => 'Pengeluaran',
        ActivityType.income => 'Pemasukan',
        ActivityType.saving => 'Nabung',
      };
}

class Saving {
  Saving({
    required this.name,
    required this.target,
    required this.current,
    required this.note,
    this.category = 'Lainnya',
    this.id,
  });

  final int? id;
  final String name;
  final double target;
  double current;
  final String note;
  final String category;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);
}

class UkuStore extends ChangeNotifier {
  UkuStore() : _persistChanges = false, _api = null;

  UkuStore._persisted() : _persistChanges = true, _api = null;

  UkuStore._apiBacked(this._api) : _persistChanges = false;

  static const _budgetKey = 'financial.budget';
  static const _budgetMonthKey = 'financial.budget_month';
  static const _expensesKey = 'financial.expenses';

  final bool _persistChanges;
  final MobileApi? _api;
  bool get isApiBacked => _api != null;
  double budget = 1500000;
  DateTime budgetMonth = DateTime.now();
  double income = 1000000;

  final List<FinancialActivity> _otherActivities = [
    FinancialActivity(
      type: ActivityType.income,
      title: 'Pemasukan bulanan',
      amount: 1000000,
      date: DateTime(2026, 9, 12),
      description: 'Pemasukan bulanan',
    ),
    FinancialActivity(
      type: ActivityType.saving,
      title: 'Jalan - jalan ke Bali',
      amount: 1000000,
      date: DateTime(2026, 9, 12),
      description: 'Setoran tabungan · Liburan',
      iconPath: categoryIconPathOrNull('Liburan'),
      category: 'Liburan',
    ),
  ];

  final List<Expense> expenses = [
    Expense(
        category: 'Pakaian',
        amount: 200000,
        date: DateTime(2026, 9, 12),
        location: 'Mall',
        purpose: 'Kebutuhan',
        method: 'Cash'),
  ];

  final List<Saving> savings = [
    Saving(
        name: 'Jalan - jalan ke Bali',
        target: 3000000,
        current: 1000000,
        note: 'Liburan',
        category: 'Liburan'),
  ];

  static Future<UkuStore> loadPersisted() async {
    final preferences = await SharedPreferences.getInstance();
    final store = UkuStore._persisted();
    final savedBudget = preferences.getDouble(_budgetKey);
    final savedBudgetMonth = preferences.getString(_budgetMonthKey);
    final savedExpenses = preferences.getString(_expensesKey);

    if (savedBudget != null) store.budget = savedBudget;
    if (savedBudgetMonth != null) {
      store.budgetMonth = DateTime.parse(savedBudgetMonth);
    }
    if (savedExpenses != null) {
      final decoded = jsonDecode(savedExpenses);
      if (decoded is! List) {
        throw const FormatException('Data pengeluaran tersimpan tidak valid');
      }
      store.expenses
        ..clear()
        ..addAll(decoded.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
                'Data pengeluaran tersimpan tidak valid');
          }
          return Expense(
            category: item['category'] as String,
            amount: (item['amount'] as num).toDouble(),
            date: DateTime.parse(item['date'] as String),
            location: item['location'] as String,
            purpose: item['purpose'] as String,
            method: item['method'] as String,
          );
        }));
    }
    return store;
  }

  static Future<UkuStore> loadFromApi(MobileApi api) async {
    final store = UkuStore._apiBacked(api);
    final results = await Future.wait([
      api.dashboard(),
      api.transactions(),
      api.savings(),
    ]);
    final dashboard = results[0] as Map<String, dynamic>;
    final transactions = results[1] as List<Map<String, dynamic>>;
    final remoteSavings = results[2] as List<Map<String, dynamic>>;

    store.expenses.clear();
    store._otherActivities.clear();
    store.savings.clear();
    store.budget = (dashboard['budget'] as num?)?.toDouble() ?? 0;
    store.income = (dashboard['income'] as num?)?.toDouble() ?? 0;
    store.budgetMonth = DateTime.parse(
        '${dashboard['month'] ?? DateTime.now().toIso8601String().substring(0, 7)}-01');

    for (final item in transactions) {
      final date = DateTime.parse(item['date'] as String);
      final amount = (item['amount'] as num).toDouble();
      final type = item['type'] as String;
      if (type == 'expense') {
        store.expenses.add(Expense(
          category: item['category'] as String,
          amount: amount,
          date: date,
          location: item['location'] as String? ?? '',
          purpose: item['purpose'] as String? ?? '',
          method: item['method'] as String? ?? '',
        ));
      } else {
        store._otherActivities.add(FinancialActivity(
          type: type == 'income' ? ActivityType.income : ActivityType.saving,
          title: item['title'] as String? ?? item['category'] as String,
          amount: amount,
          date: date,
          description: item['purpose'] as String? ?? '',
          location: item['location'] as String? ?? '',
          method: item['method'] as String? ?? '',
          category: item['category'] as String?,
        ));
      }
    }
    for (final item in remoteSavings) {
      store.savings.add(Saving(
        id: (item['id'] as num).toInt(),
        name: item['name'] as String,
        target: (item['target'] as num).toDouble(),
        current: (item['current'] as num).toDouble(),
        note: item['note'] as String? ?? '',
        category: item['category'] as String? ?? 'Lainnya',
      ));
    }
    return store;
  }

  Future<void> persistFinancialData() async {
    if (!_persistChanges) return;
    final preferences = await SharedPreferences.getInstance();
    final savedBudget = await preferences.setDouble(_budgetKey, budget);
    final savedBudgetMonth = await preferences.setString(
      _budgetMonthKey,
      budgetMonth.toIso8601String(),
    );
    final savedExpenses = await preferences.setString(
      _expensesKey,
      jsonEncode(expenses
          .map((expense) => {
                'category': expense.category,
                'amount': expense.amount,
                'date': expense.date.toIso8601String(),
                'location': expense.location,
                'purpose': expense.purpose,
                'method': expense.method,
              })
          .toList()),
    );
    if (!savedBudget || !savedBudgetMonth || !savedExpenses) {
      throw Exception('Gagal menyimpan data keuangan');
    }
  }

  double get totalExpense => expenses.fold(0, (sum, item) => sum + item.amount);
  Saving? get latestSaving => savings.isEmpty ? null : savings.last;
  bool get isOverBudget =>
      hasBudgetForMonth(DateTime.now()) && remainingBudget < 0;

  double get remainingBudget =>
      (hasBudgetForMonth(DateTime.now()) ? budget : 0) -
      expensesForMonth(DateTime.now())
          .fold(0, (sum, expense) => sum + expense.amount);

  bool hasBudgetForMonth(DateTime month) =>
      budgetMonth.year == month.year && budgetMonth.month == month.month;

  List<FinancialActivity> get activities => [
        ...expenses.map((expense) => FinancialActivity(
              type: ActivityType.expense,
              title: expense.category,
              amount: expense.amount,
              date: expense.date,
              description: expense.purpose,
              location: expense.location,
              method: expense.method,
              iconPath: categoryIconPathOrNull(expense.category),
              category: expense.category,
            )),
        ..._otherActivities,
      ]..sort((a, b) => b.date.compareTo(a.date));

  List<FinancialActivity> activitiesForMonth(DateTime month) {
    return activities
        .where((activity) =>
            activity.date.year == month.year &&
            activity.date.month == month.month)
        .toList();
  }

  void addExpense(Expense expense) {
    expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> recordExpense(Expense expense) async {
    final api = _api;
    if (api != null) {
      await api.createTransaction(
        type: 'expense',
        category: expense.category,
        amount: expense.amount,
        date: expense.date.toIso8601String().substring(0, 10),
        location: expense.location,
        purpose: expense.purpose,
        method: expense.method,
      );
    }
    addExpense(expense);
    if (api == null) await persistFinancialData();
  }

  void setBudget(double value) {
    budget = value;
    budgetMonth = DateTime.now();
    notifyListeners();
  }

  Future<void> saveBudget(double value) async {
    final api = _api;
    if (api != null) {
      final month = DateTime.now().toIso8601String().substring(0, 7);
      await api.saveBudget(value, month);
    }
    setBudget(value);
    if (api == null) await persistFinancialData();
  }

  void addSaving(String name, double target, String note,
      {String category = 'Lainnya'}) {
    savings.add(Saving(
        name: name,
        target: target,
        current: 0,
        note: note,
        category: category));
    notifyListeners();
  }

  Future<void> createSaving({
    required String name,
    required double target,
    required String note,
    required String category,
  }) async {
    final api = _api;
    final id = api == null
        ? null
        : await api.createSaving(
            name: name,
            target: target,
            note: note,
            category: category,
          );
    savings.add(Saving(
      id: id,
      name: name,
      target: target,
      current: 0,
      note: note,
      category: category,
    ));
    notifyListeners();
  }

  void addSavingBalance(Saving saving, double amount) {
    saving.current += amount;
    income += amount;
    _otherActivities.insert(
      0,
      FinancialActivity(
        type: ActivityType.saving,
        title: saving.name,
        amount: amount,
        date: DateTime.now(),
        description: 'Setoran tabungan · ${saving.category}',
        iconPath: categoryIconPathOrNull(saving.category) ??
            'assets/icons/LoveforMoney.png',
        category: saving.category,
      ),
    );
    notifyListeners();
  }

  Future<void> addSavingDeposit(Saving saving, double amount) async {
    final api = _api;
    if (api != null) {
      final id = saving.id;
      if (id == null) throw StateError('ID target tabungan tidak tersedia.');
      await api.addSavingDeposit(savingId: id, amount: amount);
    }
    addSavingBalance(saving, amount);
  }

  List<Expense> expensesForMonth(DateTime month) {
    return expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
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
