import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/savings/saving_categories.dart';
import 'package:uku_app/features/savings/saving_details_screen.dart';

class SavingCreationScreen extends StatefulWidget {
  const SavingCreationScreen({super.key, required this.store});

  final UkuStore store;

  @override
  State<SavingCreationScreen> createState() => _SavingCreationScreenState();
}

class _SavingCreationScreenState extends State<SavingCreationScreen> {
  static const _categories = SavingCategory.all;

  void _selectCategory(SavingCategory category) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SavingDetailsScreen(
          store: widget.store,
          category: category,
        ),
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
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFAAE36),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 58),
                    child: const Text(
                      'Buat Tabungan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildCategoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Semantics(
          button: true,
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
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(fontSize: 10, height: 1.1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
