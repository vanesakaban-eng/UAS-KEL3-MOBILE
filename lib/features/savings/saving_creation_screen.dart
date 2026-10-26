import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';
import 'package:uku_app/features/savings/saving_details_screen.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class SavingCreationScreen extends StatefulWidget {
  const SavingCreationScreen({super.key, required this.store});

  final UkuStore store;

  @override
  State<SavingCreationScreen> createState() => _SavingCreationScreenState();
}

class _SavingCreationScreenState extends State<SavingCreationScreen> {
  static const _categories = SavingCategory.all;
  String? _selectedCategory;

  void _selectCategory(SavingCategory category) {
    setState(() => _selectedCategory = category.name);
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted || _selectedCategory != category.name) return;
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => SavingDetailsScreen(
            store: widget.store,
            category: category,
          ),
        ),
      );
    });
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
                        'Pilih jenis tabungan',
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
                  const SizedBox(height: 8),
                  _buildCategoryGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 88,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = _selectedCategory == category.name;
        return Semantics(
          button: true,
          selected: selected,
          label: category.name,
          child: InkWell(
            onTap: () => _selectCategory(category),
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        selected ? const Color(0xFFF9C846) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFAAE36)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    category.iconPath,
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1.1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
