import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class SavingDetailsScreen extends StatefulWidget {
  const SavingDetailsScreen({
    super.key,
    required this.store,
    required this.category,
  });

  final UkuStore store;
  final SavingCategory category;

  @override
  State<SavingDetailsScreen> createState() => _SavingDetailsScreenState();
}

class _SavingDetailsScreenState extends State<SavingDetailsScreen> {
  static const _orange = Color(0xFFFA9D2B);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.store.createSaving(
        name: _nameController.text.trim(),
        target: _parseAmount(_targetController.text),
        note: _noteController.text.trim(),
        category: widget.category.name,
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target tabungan gagal disimpan.')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(String label, {String? hint, String? prefix}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black12),
    );

    return InputDecoration(
      hintText: label,
      prefixText: prefix,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _orange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    top: 12,
                    child: AppBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 58),
                      child: const Text(
                        'Buat Tabungan',
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    children: [
                      const SizedBox(height: 14),
                      const Text('Nama Tabungan',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _nameController,
                        decoration: _decoration('Contoh: Liburan ke Bali'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Masukkan nama tabungan'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      const Text('Target Tabungan',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          'Target Tabungan',
                          prefix: 'Rp ',
                        ),
                        validator: (value) => _parseAmount(value ?? '') <= 0
                            ? 'Masukkan target lebih dari Rp 0'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      const Text('Catatan',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _noteController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _decoration(
                          'Catatan',
                          hint: 'Opsional',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      const Text('Jenis Pengeluaran',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 7),
                      InputDecorator(
                        decoration: _decoration(''),
                        child: Text(widget.category.name),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Buat Tabungan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
