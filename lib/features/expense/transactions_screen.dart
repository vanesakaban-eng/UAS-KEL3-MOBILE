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
  bool _showFilters = false;

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
        final selectedCategory = categories.contains(_selectedCategory)
            ? _selectedCategory
            : null;
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
                            onPressed: () =>
                                setState(() => _showFilters = !_showFilters),
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
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis transaksi',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTypeFilter('Tabungan', ActivityType.saving),
                            _buildTypeFilter(
                                'Pengeluaran', ActivityType.expense),
                            _buildTypeFilter('Pemasukan', ActivityType.income),
                          ],
                        ),
                      ),
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedType == ActivityType.saving
                              ? 'Jenis tabungan'
                              : 'Jenis pengeluaran',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryFilter('Semua', null,
                                  selectedCategory),
                              for (final category in categories)
                                _buildCategoryFilter(
                                  category,
                                  category,
                                  selectedCategory,
                                ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildTypeFilter(String label, ActivityType type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedType == type,
        selectedColor: const Color(0xFFFFDFAE),
        side: BorderSide(
          color: _selectedType == type
              ? const Color(0xFFFAAE36)
              : Colors.black12,
        ),
        onSelected: (_) => setState(() {
          _selectedType = _selectedType == type ? null : type;
          _selectedCategory = null;
        }),
      ),
    );
  }

  Widget _buildCategoryFilter(
    String label,
    String? category,
    String? selectedCategory,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedCategory == category,
        selectedColor: const Color(0xFFFFDFAE),
        side: BorderSide(
          color: selectedCategory == category
              ? const Color(0xFFFAAE36)
              : Colors.black12,
        ),
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
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
