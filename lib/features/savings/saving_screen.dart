import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_creation_screen.dart';
import 'package:uku_app/features/savings/saving_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedSaving != null
          ? SavingDetailScreen(
              store: widget.store,
              saving: _selectedSaving!,
              onBack: () => setState(() => _selectedSaving = null),
              onHome: widget.onBack ?? () => Navigator.of(context).maybePop(),
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
    return SavingCard(
      store: widget.store,
      saving: saving,
      onTap: () => setState(() => _selectedSaving = saving),
    );
  }
}
