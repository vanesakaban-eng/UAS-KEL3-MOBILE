import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, required this.store});

  final UkuStore store;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _isEditing = false;
  final _budgetController = TextEditingController();

  void _openBudgetEditor() {
    final hasCurrentMonthBudget =
        widget.store.hasBudgetForMonth(DateTime.now());
    _budgetController.text = hasCurrentMonthBudget
        ? rupiah(widget.store.budget).replaceFirst('Rp ', '')
        : '';
    setState(() => _isEditing = true);
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
    setState(() => _isEditing = false);
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
        if (_isEditing) {
          return SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 12,
                        child: AppBackButton(
                          onPressed: () => setState(() => _isEditing = false),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 58),
                          child: const Text(
                            'Budget',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                            Expanded(
                              child: Text(
                                hasCurrentMonthBudget
                                    ? 'Edit Budget Bulan Ini'
                                    : 'Buat Budget Bulan Ini',
                                style: const TextStyle(
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
                        const SizedBox(height: 1),
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
        }

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
                      child: InkWell(
                        onTap: _openBudgetEditor,
                        borderRadius: BorderRadius.circular(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasCurrentMonthBudget
                                  ? 'Budget bulan ini'
                                  : 'Buat Budget bulan ini',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (hasCurrentMonthBudget) ...[
                              const SizedBox(height: 2),
                              const Text(
                                'Klik untuk edit budget bulanan',
                                style: TextStyle(
                                  color: Color(0x99000000),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                            const SizedBox(height: 3),
                            Container(
                              width: 142,
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
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        hasCurrentMonthBudget
                                            ? rupiah(widget.store.budget)
                                                .replaceFirst('Rp ', '')
                                            : 'Atur sekarang',
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Buat Budget',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/icons/Budget (1).png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Budget per bulan',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 10),
                          ),
                          if (hasCurrentMonthBudget) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Budget bulan ini sudah dibuat. Edit melalui kartu Budget bulan ini.',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          const SizedBox(height: 7),
                          TextField(
                            controller: _budgetController,
                            enabled: !hasCurrentMonthBudget,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan nominal',
                              hintStyle: const TextStyle(
                                color: Colors.black38,
                                fontSize: 11,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFAD2F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed:
                                  hasCurrentMonthBudget ? null : _saveBudget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFAD2F),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFFFFD99E),
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(fontSize: 16),
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
        );
      },
    );
  }
}
