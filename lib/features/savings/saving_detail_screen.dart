import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';

class SavingDetailScreen extends StatefulWidget {
  const SavingDetailScreen({
    super.key,
    required this.store,
    required this.saving,
  });

  final UkuStore store;
  final Saving saving;

  @override
  State<SavingDetailScreen> createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends State<SavingDetailScreen> {
  Future<void> _addBalance() async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _AddBalanceDialog(),
    );

    if (amount != null && mounted) {
      widget.store.addSavingBalance(widget.saving, amount);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.saving;
    final remaining = saving.target - saving.current;
    final progress = saving.progress * 100;
    final category = SavingCategory.fromName(saving.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Detail Tabungan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAAE36).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        category.iconPath,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        saving.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saldo terkini'),
                    Text(
                      rupiah(saving.current),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Target'),
                    Text(
                      rupiah(saving.target),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: saving.progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFFEDEDED),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFAAE36),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$progress% tercapai'),
                    Text(
                      'Sisa ${rupiah(remaining)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (saving.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Catatan: ${saving.note}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _addBalance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAAE36),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tambah Saldo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBalanceDialog extends StatefulWidget {
  const _AddBalanceDialog();

  @override
  State<_AddBalanceDialog> createState() => _AddBalanceDialogState();
}

class _AddBalanceDialogState extends State<_AddBalanceDialog> {
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
