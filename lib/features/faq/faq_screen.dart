import 'package:flutter/material.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

const faqItems = [
  FaqItem(
    question: 'Apa itu UKU App?',
    answer:
        'UKU adalah aplikasi untuk membantu mencatat pengeluaran, mengatur budget, dan memantau target tabungan dalam satu tempat.',
  ),
  FaqItem(
    question: 'Bagaimana cara mengatur budget bulanan?',
    answer:
        'Buka menu Budget, masukkan jumlah anggaran untuk bulan ini, lalu simpan. Pengeluaran yang dicatat akan diperhitungkan terhadap budget tersebut.',
  ),
  FaqItem(
    question: 'Kapan notifikasi AI akan muncul?',
    answer:
        'AIKu menganalisis pengeluaran bulan berjalan. Insight akan memberi peringatan saat pemakaian budget mendekati atau melewati batas.',
  ),
  FaqItem(
    question: 'Bagaimana cara melihat riwayat transaksi?',
    answer:
        'Pilih Rekap Aktivitas dari halaman Beranda untuk melihat transaksi dan ringkasan berdasarkan bulan.',
  ),
  FaqItem(
    question: 'Bagaimana jika aplikasi mengalami error?',
    answer:
        'Pastikan aplikasi dan koneksi internet berfungsi, lalu coba kembali. Jika masalah berlanjut, hubungi tim dukungan UKU melalui kanal resmi.',
  ),
  FaqItem(
    question: 'Bagaimana cara mencatat pengeluaran dari bill?',
    answer:
        'Pilih Foto Bill, tentukan kategori, lalu ambil foto bill atau pilih gambar dari galeri. Periksa kembali hasil pembacaan dan pilih metode pembayaran sebelum menyimpan.',
  ),
  FaqItem(
    question: 'Bagaimana cara membuat target tabungan?',
    answer:
        'Pilih Nabung di halaman Beranda, buat target beserta nominalnya, lalu catat setoran untuk memantau progres tabungan.',
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _orange = Color(0xFFFF8800);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 11,
                    child: AppBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'FAQ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const Text(
                    'Pertanyaan Umum',
                    style: TextStyle(
                      color: Color(0xFF70420F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FaqList(items: faqItems),
                  const SizedBox(height: 14),
                  _HelpCard(onTap: () => _showHelpDialog(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.support_agent_rounded, color: _orange),
        title: const Text('Butuh bantuan lainnya?'),
        content: const Text(
          'Silakan hubungi tim dukungan UKU melalui kanal bantuan resmi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti', style: TextStyle(color: _orange)),
          ),
        ],
      ),
    );
  }
}

class HomeFaqSection extends StatelessWidget {
  const HomeFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Pertanyaan Umum',
                  style: TextStyle(
                    color: Color(0xFF70420F),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const FaqScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: FaqScreen._orange,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _FaqList(items: faqItems.take(5).toList()),
          const SizedBox(height: 12),
          _HelpCard(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const FaqScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqList extends StatefulWidget {
  const _FaqList({required this.items});

  final List<FaqItem> items;

  @override
  State<_FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<_FaqList> {
  late final List<ExpansibleController> _controllers =
      List.generate(widget.items.length, (_) => ExpansibleController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var index = 0; index < widget.items.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(height: 1, color: Color(0xFFFFE3C2)),
              ),
            Material(
              color: Colors.white,
              child: ExpansionTile(
                controller: _controllers[index],
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                iconColor: FaqScreen._orange,
                collapsedIconColor: FaqScreen._orange,
                onExpansionChanged: (expanded) {
                  if (!expanded) return;
                  for (var otherIndex = 0;
                      otherIndex < _controllers.length;
                      otherIndex++) {
                    if (otherIndex != index) {
                      _controllers[otherIndex].collapse();
                    }
                  }
                },
                title: Text(
                  widget.items[index].question,
                  style: const TextStyle(
                    color: Color(0xFF553A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.items[index].answer,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE8CC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: Color(0xFFE87500)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh bantuan lainnya?',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Buka pusat bantuan UKU',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 15, color: Color(0xFFE87500)),
            ],
          ),
        ),
      ),
    );
  }
}
