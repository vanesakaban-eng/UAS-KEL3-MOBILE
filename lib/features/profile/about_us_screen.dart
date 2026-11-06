import 'package:flutter/material.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _orange = Color(0xFFFF8800);
  static const _yellow = Color(0xFFFFD84D);
  static const _textColor = Color(0xFF282828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Tentang Kami',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // const _AboutLogoBanner(),
            const SizedBox(height: 14),
            _AboutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intelligent Personal Finance & Budget Manager',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'UKU (Uang Ku) merupakan aplikasi pengelolaan keuangan pribadi yang dirancang untuk membantu pengguna mengatur dan memantau kondisi keuangan secara lebih mudah, praktis, dan terencana.',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AboutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visi & Misi',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Menjadi solusi pengelolaan keuangan pribadi yang cerdas, praktis, dan mudah digunakan untuk membantu masyarakat mencapai kondisi keuangan yang lebih baik.',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final mission in const [
                    'Mempermudah pencatatan pemasukan dan pengeluaran.',
                    'Membantu pengguna mengatur anggaran bulanan.',
                    'Menyediakan informasi keuangan yang mudah dipahami.',
                    'Memanfaatkan AI untuk memberikan insight dan rekomendasi pengelolaan keuangan.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ', style: TextStyle(fontSize: 11)),
                          Expanded(
                            child: Text(
                              mission,
                              style: const TextStyle(
                                color: _textColor,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur Utama',
              style: TextStyle(
                color: _textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _FeatureList()),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: _yellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tim Pengembang',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        _TeamBullet('Kelompok 3 Kelas T3D'),
                        _TeamBullet('D3 Teknologi Informasi'),
                        _TeamBullet('Fakultas Vokasi USB'),
                        _TeamBullet('Tahun 2026/2027'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Kelola Uangmu, Rencanakan Masa Depanmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '© 2026 UKU. Seluruh hak cipta dilindungi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// class _AboutLogoBanner extends StatelessWidget {
//   const _AboutLogoBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: AboutUsScreen._yellow,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(17),
//             child: Image.asset(
//               'assets/image/Logo.png',
//               width: 40,
//               height: 40,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: FittedBox(
//               alignment: Alignment.centerLeft,
//               fit: BoxFit.scaleDown,
//               child: Text.rich(
//                 TextSpan(
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 3,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: 'U',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     TextSpan(
//                       text: 'K',
//                       style: TextStyle(color: AboutUsScreen._orange),
//                     ),
//                     TextSpan(
//                       text: 'u',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _features = [
    ('assets/icons/Plus.png', 'Catat Pengeluaran'),
    ('assets/icons/Spiral Bound Booklet.png', 'Rekap Aktivitas'),
    ('assets/icons/Love for Money.png', 'Target Tabungan'),
    ('assets/icons/AI.png', 'AIKu Notifikasi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final feature in _features)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Image.asset(
                  feature.$1,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feature.$2,
                    style: const TextStyle(
                      color: AboutUsScreen._textColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TeamBullet extends StatelessWidget {
  const _TeamBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 10)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AboutUsScreen._textColor,
                fontSize: 9,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
