import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, required this.store});

  final UkuStore store;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.store.hasBudgetForMonth(DateTime.now())) {
      _budgetController.text =
          rupiah(widget.store.budget).replaceFirst('Rp ', '');
    }
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(
      _budgetController.text.replaceAll('.', '').replaceAll(',', '').trim(),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal budget yang valid')),
      );
      return;
    }

    var saveMessage = 'Budget berhasil disimpan';
    try {
      await widget.store.saveBudget(amount);
    } on Exception {
      if (widget.store.isApiBacked) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget gagal disimpan ke server.')),
        );
        return;
      }
      saveMessage =
          'Budget diubah, tetapi gagal disimpan untuk sesi berikutnya.';
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(saveMessage)),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final hasCurrentMonthBudget =
            widget.store.hasBudgetForMonth(DateTime.now());
        return SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFFFAAE36)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 58),
                        child: const Text(
                          'Budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      top: 92,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget bulan ini',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 180,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Rp',
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      rupiah(hasCurrentMonthBudget
                                              ? widget.store.budget
                                              : 0)
                                          .replaceFirst('Rp ', ''),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Edit Budget Bulan Ini',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/icons/Budget (1).png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const Text(
                        'Budget per bulan',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'type here',
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.black38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFAD2F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFAD2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
