const categoryIcons = <String, String>{
  'Makanan & Minuman': 'assets/icons/Restaurant.png',
  'Hiburan': 'assets/icons/3D Glasses.png',
  'Pendidikan': 'assets/icons/Online Group Studying.png',
  'Donasi': 'assets/icons/Charity.png',
  'Pakaian': 'assets/icons/Clothes.png',
  'Kebutuhan Rumah': 'assets/icons/House.png',
  'Transportasi': 'assets/icons/Public Transportation.png',
  'Kecantikan': 'assets/icons/Beautician.png',
  'Liburan': 'assets/icons/Airplane Landing.png',
  'Kesehatan': 'assets/icons/Hospital Room.png',
  'Belanja': 'assets/icons/Shopping Bag.png',
  'Hewan Peliharaan': 'assets/icons/Pet Commands Summon.png',
};

String? categoryIconPathOrNull(String category) => categoryIcons[category];

String categoryIconPath(String category) =>
    categoryIcons[category] ??
    (throw ArgumentError.value(category, 'category', 'No icon configured'));
