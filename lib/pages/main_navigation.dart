import 'package:flutter/material.dart';
import '../data/uku_store.dart';
import 'home_screen.dart';
import 'expense_screen.dart';
import 'monthly_expense_screen.dart';
import 'budget_screen.dart';
import 'transactions_screen.dart';
import 'recap_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final UkuStore store = UkuStore();
  int currentIndex = 0;

  void openExpense() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(body: ExpenseScreen(store: store)),
      ),
    );
  }

  void openBudget() => setState(() => currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (label: 'Beranda'),
      (label: 'Pengeluaran'),
      (label: 'Budget'),
      (label: 'Transaksi'),
    ];
    final pages = [
      HomeScreenContent(
        store: store,
        onExpense: openExpense,
        onBudget: openBudget,
      ),
      MonthlyExpenseScreen(
        store: store,
        onBack: () => setState(() => currentIndex = 0),
      ),
      BudgetScreen(store: store),
      TransactionsScreen(
        store: store,
        onBack: () => setState(() => currentIndex = 0),
      ),
    ];
    return Scaffold(
      body: pages[currentIndex],
      floatingActionButton: currentIndex == 0 ? null : null,
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: currentIndex == index,
                      label: destinations[index].label,
                      child: InkWell(
                        onTap: () => setState(() => currentIndex = index),
                        child: SizedBox.expand(
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 3,
                                color: currentIndex == index
                                    ? const Color(0xFFFAAE36)
                                    : Colors.transparent,
                              ),
                              const SizedBox(height: 8),
                              if (index == 0)
                                ImageIcon(
                                  AssetImage(
                                    currentIndex == index
                                        ? 'assets/icons/Home Page (1).png'
                                        : 'assets/icons/Home Page.png',
                                  ),
                                  size: 25,
                                  color: currentIndex == index
                                      ? const Color(0xFFFAAE36)
                                      : const Color(0xFFD0D0D0),
                                )
                              else if (index == 1)
                                ImageIcon(
                                  AssetImage(
                                    currentIndex == index
                                        ? 'assets/icons/Initiate Money Transfer (1).png'
                                        : 'assets/icons/Initiate Money Transfer.png',
                                  ),
                                  size: 25,
                                  color: currentIndex == index
                                      ? const Color(0xFFFAAE36)
                                      : const Color(0xFFD0D0D0),
                                )
                              else if (index == 2)
                                ImageIcon(
                                  AssetImage(
                                    currentIndex == index
                                        ? 'assets/icons/Budget (1).png'
                                        : 'assets/icons/Budget.png',
                                  ),
                                  size: 25,
                                  color: currentIndex == index
                                      ? const Color(0xFFFAAE36)
                                      : const Color(0xFFD0D0D0),
                                )
                              else
                                ImageIcon(
                                  AssetImage(
                                    currentIndex == index
                                        ? 'assets/icons/Payment History.png'
                                        : 'assets/icons/Payment History (1).png',
                                  ),
                                  size: 25,
                                  color: currentIndex == index
                                      ? const Color(0xFFFAAE36)
                                      : const Color(0xFFD0D0D0),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                destinations[index].label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpenRecapButton extends StatelessWidget {
  const OpenRecapButton({super.key, required this.store});
  final UkuStore store;
  @override
  Widget build(BuildContext context) => IconButton(
      icon: const Icon(Icons.bar_chart),
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => RecapScreen(store: store))));
}
