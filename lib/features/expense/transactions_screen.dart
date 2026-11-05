import 'package:flutter/material.dart';

import 'package:uku_app/data/category_icons.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.store, this.onBack});

  final UkuStore store;
  final VoidCallback? onBack;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  ActivityType? _selectedType;
  String? _selectedCategory;

  Future<void> _openFilters() async {
    var draftType = _selectedType;
    var draftCategory = _selectedCategory;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final categories = switch (draftType) {
            ActivityType.expense => categoryIcons.keys.toList()..sort(),
            ActivityType.saving =>
              SavingCategory.all.map((category) => category.name).toList(),
            _ => <String>[],
          };
          final selectedCategory =
              categories.contains(draftCategory) ? draftCategory : null;
          final sheetHeight = MediaQuery.sizeOf(context).height * 0.78;

          return SafeArea(
            top: false,
            child: Container(
              height: sheetHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'Pilih Filter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: IconButton(
                            tooltip: 'Tutup filter',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon:
                                const Icon(Icons.close, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEFEFEF)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jenis transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Tabungan',
                                draftType == ActivityType.saving,
                                () => setSheetState(() {
                                  draftType = draftType == ActivityType.saving
                                      ? null
                                      : ActivityType.saving;
                                  draftCategory = null;
                                }),
                                selectedColor: const Color(0xFFFF8800),
                                selectedLabelColor: Colors.white,
                              ),
                              _buildFilterChip(
                                'Pengeluaran',
                                draftType == ActivityType.expense,
                                () => setSheetState(() {
                                  draftType = draftType == ActivityType.expense
                                      ? null
                                      : ActivityType.expense;
                                  draftCategory = null;
                                }),
                                selectedColor: const Color(0xFFFF8800),
                                selectedLabelColor: Colors.white,
                              ),
                              _buildFilterChip(
                                'Pemasukan',
                                draftType == ActivityType.income,
                                () => setSheetState(() {
                                  draftType = draftType == ActivityType.income
                                      ? null
                                      : ActivityType.income;
                                  draftCategory = null;
                                }),
                                selectedColor: const Color(0xFFFF8800),
                                selectedLabelColor: Colors.white,
                              ),
                            ],
                          ),
                          if (categories.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            Text(
                              draftType == ActivityType.saving
                                  ? 'Jenis tabungan'
                                  : 'Jenis pengeluaran',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterChip(
                                  'Semua',
                                  selectedCategory == null,
                                  () =>
                                      setSheetState(() => draftCategory = null),
                                ),
                                for (final category in categories)
                                  _buildFilterChip(
                                    category,
                                    selectedCategory == category,
                                    () => setSheetState(
                                        () => draftCategory = category),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEFEFEF)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setSheetState(() {
                              draftType = null;
                              draftCategory = null;
                            }),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFFAD2F),
                              side: const BorderSide(color: Color(0xFFFFAD2F)),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Atur Ulang'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedType = draftType;
                                _selectedCategory = draftCategory;
                              });
                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFAD2F),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final allActivities = widget.store.activities;
        final categories = switch (_selectedType) {
          ActivityType.expense => categoryIcons.keys.toList()..sort(),
          ActivityType.saving =>
            SavingCategory.all.map((category) => category.name).toList(),
          _ => <String>[],
        };
        final selectedCategory =
            categories.contains(_selectedCategory) ? _selectedCategory : null;
        final activities = allActivities.where((activity) {
          return (_selectedType == null || activity.type == _selectedType) &&
              (selectedCategory == null ||
                  activity.category == selectedCategory);
        }).toList();
        final latestDate = activities.isEmpty ? null : activities.first.date;

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
                        onPressed: widget.onBack ??
                            () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 12,
                      top: 48,
                      bottom: 0,
                      child: Row(
                        children: [
                          const SizedBox(width: 48),
                          const Expanded(
                            child: Text(
                              'Riwayat Transaksi',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Filter transaksi',
                            onPressed: _openFilters,
                            icon: Image.asset(
                              'assets/icons/Group 74.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allActivities.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : activities.isEmpty
                        ? Center(
                            child: Text(
                              selectedCategory != null
                                  ? 'Tidak ada ${_activityTypeLabel(_selectedType)} untuk kategori $selectedCategory'
                                  : 'Tidak ada ${_activityTypeLabel(_selectedType)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: activities.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    _formatDate(latestDate!),
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return _ActivityDetails(
                                activity: activities[index - 1],
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    Color selectedColor = const Color(0xFFFFAD2F),
    Color selectedLabelColor = const Color.fromARGB(255, 255, 255, 255),
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: selectedColor,
      backgroundColor: const Color(0xFFF4F4F4),
      side: BorderSide(
        color: selected ? selectedColor : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: TextStyle(
        color: selected ? selectedLabelColor : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

String _activityTypeLabel(ActivityType? type) {
  return switch (type) {
    ActivityType.expense => 'pengeluaran',
    ActivityType.income => 'pemasukan',
    ActivityType.saving => 'tabungan',
    null => 'transaksi',
  };
}

class _ActivityDetails extends StatelessWidget {
  const _ActivityDetails({required this.activity});

  final FinancialActivity activity;

  @override
  Widget build(BuildContext context) {
    final color = switch (activity.type) {
      ActivityType.expense => const Color(0xFFE65353),
      ActivityType.income => const Color(0xFF278A5B),
      ActivityType.saving => const Color(0xFFFAAE36),
    };
    final icon = switch (activity.type) {
      ActivityType.expense => Icons.payments_outlined,
      ActivityType.income => Icons.south_west,
      ActivityType.saving => Icons.savings_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.iconPath case final iconPath?)
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            )
          else
            Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${activity.typeLabel} · ${_formatDate(activity.date)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
                if (activity.description.isNotEmpty &&
                    activity.description != activity.title)
                  Text(
                    activity.description,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                if (activity.method.isNotEmpty)
                  Text(
                    'Metode: ${activity.method}',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                if (activity.location.isNotEmpty)
                  Text(
                    'Lokasi: ${activity.location}',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${activity.type == ActivityType.expense ? '-' : '+'} ${rupiah(activity.amount)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}
