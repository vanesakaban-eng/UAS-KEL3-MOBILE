import 'package:flutter/material.dart';
import 'edit_profil.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card Saldo
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFA9D2B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Halo, User',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Image.asset('assets/image/profil.png', height: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Sisa Budget', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Rp  1.300.000',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoBox('Pengeluaran', 'Rp  200.000'),
                      const SizedBox(width: 10),
                      _buildInfoBox('Pemasukkan', 'Rp  1.000.000'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Catat Pengeluaran
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Colors.black12),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/Plus.png', height: 22),
                  const SizedBox(width: 8),
                  const Text('Catat Pengeluaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Menu Quick Action
            Row(
              children: [
                Expanded(child: _buildActionCard('assets/icons/PaymentHistory.png', 'Rekap Aktivitas')),
                const SizedBox(width: 12),
                Expanded(child: _buildActionCard('assets/icons/LoveforMoney.png', 'Nabung')),
              ],
            ),
            const SizedBox(height: 16),

            // Transaksi Terakhir
            _buildSectionCard(
              title: 'Transaksi',
              iconPath: 'assets/icons/PaymentHistory.png',
              subtitle: 'Sabtu, 12 September 2026',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA9D2B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pakaian', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                    Text('- 200.000', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Nabung
            _buildSectionCard(
              title: 'Nabung',
              iconPath: 'assets/icons/LoveforMoney.png',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA9D2B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jalan - jalan ke Bali', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                        Text('+1.000.000', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Liburan', style: TextStyle(color: Colors.black54, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // AI Notifikasi
            _buildSectionCard(
              title: 'AI Notifikasi',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kondisi keuangan saat ini', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF9C846),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String iconPath, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset(iconPath, height: 36),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, String? iconPath, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 6),
              if (iconPath != null) Image.asset(iconPath, height: 18),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}