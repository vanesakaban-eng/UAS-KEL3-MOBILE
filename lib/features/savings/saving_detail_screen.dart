import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class SavingDetailScreen extends StatefulWidget {
  const SavingDetailScreen({
    super.key,
    required this.store,
    required this.saving,
    this.onBack,
  });

  final UkuStore store;
  final Saving saving;
  final VoidCallback? onBack;

  @override
  State<SavingDetailScreen> createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends State<SavingDetailScreen> {
  static const _orange = Color(0xFFFFA927);

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Widget _detailField(String value) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black38),
      ),
      child: Text(
        value,
        style: const TextStyle(color: Colors.black45, fontSize: 10),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _detailField(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.saving;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      onPressed: _goBack,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 58),
                      child: Text(
                        'Detail Tabungan',
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                        _detailItem('Nama tabungan', saving.name),
                        const SizedBox(height: 14),
                        _detailItem('Target tabungan', rupiah(saving.target)),
                        const SizedBox(height: 14),
                        _detailItem(
                          'Catatan',
                          saving.note.isEmpty ? '-' : saving.note,
                        ),
                        const SizedBox(height: 14),
                        _detailItem('Jenis tabungan', saving.category),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _goBack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(fontSize: 18),
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
    );
  }
}
