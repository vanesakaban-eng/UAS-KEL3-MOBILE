import 'package:flutter/material.dart';
import 'package:uku_app/data/category_icons.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';

class ActivityFilter {
  const ActivityFilter({this.type, this.category});

  final ActivityType? type;
  final String? category;

  bool get hasFilters => type != null || category != null;
}

List<String> activityFilterCategories(ActivityType? type) => switch (type) {
      ActivityType.expense => categoryIcons.keys.toList()..sort(),
      ActivityType.saving =>
        SavingCategory.all.map((category) => category.name).toList(),
      null => {
          ...categoryIcons.keys,
          ...SavingCategory.all.map((category) => category.name),
        }.toList()
          ..sort(),
      ActivityType.income => <String>[],
    };

List<FinancialActivity> filterActivities(
  Iterable<FinancialActivity> activities,
  ActivityFilter filter,
) {
  final categories = activityFilterCategories(filter.type);
  final selectedCategory =
      categories.contains(filter.category) ? filter.category : null;

  return activities
      .where((activity) =>
          (filter.type == null || activity.type == filter.type) &&
          (selectedCategory == null || activity.category == selectedCategory))
      .toList();
}

Future<ActivityFilter?> showActivityFilterSheet(
  BuildContext context, {
  required ActivityFilter initialFilter,
}) async {
  var draftType = initialFilter.type;
  var draftCategory = initialFilter.category;

  return showModalBottomSheet<ActivityFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        final categories = activityFilterCategories(null);
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
                          icon: const Icon(Icons.close, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEFEFEF)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
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
                                selectedColor: const Color(0xFFFFAD2F),
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
                                selectedColor: const Color(0xFFFFAD2F),
                                selectedLabelColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Jenis tabungan/pengeluaran',
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
                                'Semua',
                                selectedCategory == null,
                                () => setSheetState(() => draftCategory = null),
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
                      ),
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
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            ActivityFilter(
                              type: draftType,
                              category: selectedCategory,
                            ),
                          ),
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
