import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';
import 'package:uku_app/features/savings/saving_creation_screen.dart';
import 'package:uku_app/features/savings/saving_detail_screen.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class SavingScreen extends StatefulWidget {
  const SavingScreen({
    super.key,
    required this.store,
    this.onBack,
    this.initialSaving,
  });

  final UkuStore store;
  final VoidCallback? onBack;
  final Saving? initialSaving;

  @override
  State<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends State<SavingScreen> {
  Saving? _selectedSaving;

  @override
  void initState() {
    super.initState();
    _selectedSaving = widget.initialSaving;
  }

  Future<void> _createSaving() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SavingCreationScreen(store: widget.store),
      ),
    );
    if (created == true && mounted) setState(() {});
  }

  Future<void> _addBalance(Saving saving) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _AddSavingBalanceDialog(),
    );
    if (amount != null && mounted) {
      try {
        await widget.store.addSavingDeposit(saving, amount);
        if (mounted) setState(() {});
      } on Exception {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setoran gagal disimpan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedSaving != null
          ? SavingDetailScreen(
              store: widget.store,
              saving: _selectedSaving!,
              onBack: () => setState(() => _selectedSaving = null),
            )
          : SafeArea(
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
                            onPressed: widget.onBack ??
                                () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 58),
                            child: const Text(
                              'Nabung',
                              textAlign: TextAlign.center,
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
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Target Tabungan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _createSaving,
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFFFA9D2B),
                              ),
                              label: const Text(
                                'Tambah',
                                style: TextStyle(color: Color(0xFFFA9D2B)),
                              ),
                            ),
                          ],
                        ),
                        if (widget.store.savings.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text(
                                'Belum ada target tabungan',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...widget.store.savings.map(_buildSavingCard),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSavingCard(Saving saving) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSaving = saving),
      child: Card(
        color: const Color.fromARGB(255, 254, 254, 254),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    child: Image.asset(
                      SavingCategory.fromName(saving.category).iconPath,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saving.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          saving.note.isEmpty
                              ? saving.category
                              : '${saving.category} · ${saving.note}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    rupiah(saving.current),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: saving.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: const Color.fromARGB(255, 228, 226, 218),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFAAE36),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Target ${rupiah(saving.target)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => _addBalance(saving),
                    child: const Text(
                      'Tambah saldo',
                      style: TextStyle(
                        color: Color(0xFFFA9D2B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSavingBalanceDialog extends StatefulWidget {
  const _AddSavingBalanceDialog();

  @override
  State<_AddSavingBalanceDialog> createState() =>
      _AddSavingBalanceDialogState();
}

class _AddSavingBalanceDialogState extends State<_AddSavingBalanceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Saldo'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(prefixText: 'Rp '),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(
              _controller.text.replaceAll('.', '').replaceAll(',', ''),
            );
            if (amount != null && amount > 0) {
              Navigator.pop(context, amount);
            }
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
