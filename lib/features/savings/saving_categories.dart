import 'package:uku_app/data/category_icons.dart';

class SavingCategory {
  const SavingCategory({required this.name});

  final String name;

  String get iconPath => categoryIconPath(name);

  static const List<SavingCategory> all = [
    SavingCategory(name: 'Makanan & Minuman'),
    SavingCategory(name: 'Hiburan'),
    SavingCategory(name: 'Pendidikan'),
    SavingCategory(name: 'Donasi'),
    SavingCategory(name: 'Pakaian'),
    SavingCategory(name: 'Kebutuhan Rumah'),
    SavingCategory(name: 'Transportasi'),
    SavingCategory(name: 'Kecantikan'),
    SavingCategory(name: 'Liburan'),
    SavingCategory(name: 'Kesehatan'),
    SavingCategory(name: 'Belanja'),
    SavingCategory(name: 'Hewan Peliharaan'),
  ];

  static SavingCategory fromName(String name) {
    return all.firstWhere((category) => category.name == name);
  }
}
