import 'package:flutter/material.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';

class SavingCard extends StatelessWidget {
  const SavingCard({
    super.key,
    required this.store,
    required this.saving,
    this.onTap,
  });

  final UkuStore store;
  final Saving saving;
  final VoidCallback? onTap;

  Future<void> _addBalance(BuildContext context) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _AddSavingBalanceDialog(),
    );
    if (amount == null || !context.mounted) return;

    try {
      await store.addSavingDeposit(saving, amount);
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setoran gagal disimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => GestureDetector(
        onTap: onTap,
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
                      onPressed: () => _addBalance(context),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text('Tambah Saldo'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: 'Rp ',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFAD2F)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFAD2F),
          ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFAD2F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
