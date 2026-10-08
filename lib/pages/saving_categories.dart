import 'package:flutter/material.dart';

class SavingCategory {
  const SavingCategory({
    required this.name,
    required this.iconPath,
  });

  final String name;
  final String iconPath;

  static const List<SavingCategory> all = [
    SavingCategory(
        name: 'Makanan & Minuman', iconPath: 'assets/icons/Restaurant.png'),
    SavingCategory(name: 'Hiburan', iconPath: 'assets/icons/3D Glasses.png'),
    SavingCategory(
        name: 'Pendidikan', iconPath: 'assets/icons/Online Group Studying.png'),
    SavingCategory(name: 'Donasi', iconPath: 'assets/icons/Charity.png'),
    SavingCategory(name: 'Pakaian', iconPath: 'assets/icons/Clothes.png'),
    SavingCategory(name: 'Kebutuhan Rumah', iconPath: 'assets/icons/House.png'),
    SavingCategory(
        name: 'Transportasi',
        iconPath: 'assets/icons/Public Transportation.png'),
    SavingCategory(name: 'Kecantikan', iconPath: 'assets/icons/Beautician.png'),
    SavingCategory(
        name: 'Liburan', iconPath: 'assets/icons/Airplane Landing.png'),
    SavingCategory(
        name: 'Kesehatan', iconPath: 'assets/icons/Hospital Room.png'),
    SavingCategory(name: 'Belanja', iconPath: 'assets/icons/Shopping Bag.png'),
    SavingCategory(
        name: 'Hewan Peliharaan',
        iconPath: 'assets/icons/Pet Commands Summon.png'),
  ];

  static SavingCategory fromName(String name) {
    return all.firstWhere((category) => category.name == name);
  }
}
