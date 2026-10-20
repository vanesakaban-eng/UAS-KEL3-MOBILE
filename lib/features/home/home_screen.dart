import 'package:flutter/material.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/expense/recap_screen.dart';
import 'package:uku_app/features/expense/transactions_screen.dart';
import 'package:uku_app/features/profile/edit_profil.dart';
import 'package:uku_app/features/savings/saving_detail_screen.dart';
import 'package:uku_app/features/savings/saving_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({
    super.key,
    required this.store,
    required this.onExpense,
    this.onBudget,
    this.onRecap,
    this.onSaving,
  });
  final UkuStore store;
  final VoidCallback onExpense;
  final VoidCallback? onBudget;
  final VoidCallback? onRecap;
  final VoidCallback? onSaving;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final latest = store.expenses.isEmpty ? null : store.expenses.first;
          return SafeArea(
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(color: Color(0xFFFAAE36)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Halo, User',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const EditProfileScreen())),
                                    child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        child: Image.asset(
                                            'assets/image/profil.png',
                                            height: 28)))
                              ]),
                          const SizedBox(height: 12),
                          const Text('Sisa Budget',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          InkWell(
                              onTap: onBudget,
                              borderRadius: BorderRadius.circular(10),
                              child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(rupiah(store.remainingBudget),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))))),
                          const SizedBox(height: 12),
                          Row(children: [
                            _buildInfoBox(
                                'Pengeluaran', rupiah(store.totalExpense)),
                            const SizedBox(width: 10),
                            _buildInfoBox('Pemasukkan', rupiah(store.income))
                          ]),
                        ])),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  side:
                                      const BorderSide(color: Colors.black12)),
                              onPressed: onExpense,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/icons/Plus.png',
                                        height: 22),
                                    const SizedBox(width: 8),
                                    const Text('Catat Pengeluaran',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))
                                  ])),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: _buildActionCard(
                                    'assets/icons/PaymentHistory.png',
                                    'Rekap Aktivitas',
                                    onTap: onRecap ??
                                        () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => RecapScreen(
                                                  store: store,
                                                ),
                                              ),
                                            ))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildActionCard(
                                    'assets/icons/LoveforMoney.png', 'Nabung',
                                    onTap: onSaving ??
                                    () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                        builder: (_) => SavingScreen(
                                          store: store,
                                        ),
                                          ),
                                        )))
                          ]),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                              title: 'Transaksi',
                              iconPath: 'assets/icons/PaymentHistory.png',
                              subtitle: latest == null
                                  ? 'Belum ada transaksi'
                                  : '${latest.date.day}/${latest.date.month}/${latest.date.year}',
                              onTap: () => Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionsScreen(
                                        store: store,
                                      ),
                                    ),
                                  ),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFA9D2B),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(latest?.category ?? '-',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500))),
                                    const SizedBox(width: 8),
                                    Text(
                                        latest == null
                                            ? '-'
                                            : '- ${rupiah(latest.amount)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))
                                  ]))),
                          const SizedBox(height: 14),
                          _buildSectionCard(
                              title: 'Nabung',
                              iconPath: 'assets/icons/LoveforMoney.png',
                              onTap: store.savings.isEmpty
                                  ? onSaving ??
                                      () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SavingScreen(
                                                store: store,
                                              ),
                                            ),
                                          )
                                  : () => Navigator.push<void>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SavingDetailScreen(
                                            store: store,
                                            saving: store.savings.first,
                                          ),
                                        ),
                                      ),
                              child: store.savings.isEmpty
                                  ? const Text('Belum ada target tabungan',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11))
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFFA9D2B),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(store.savings.first.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(store.savings.first.note,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11))
                                            ])),
                                        const SizedBox(width: 8),
                                        Text(
                                            '+ ${rupiah(store.savings.first.current)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ]))),
                          const SizedBox(height: 14),
                          _buildSectionCard(
                              title: 'AI Notifikasi',
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    const Expanded(
                                        child: Text('Kondisi keuangan saat ini',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))),
                                    const SizedBox(width: 8),
                                    Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                            color: store.remainingBudget >= 0
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle))
                                  ]))),
                        ])),
              ])));
        });
  }

  Widget _buildInfoBox(String label, String value) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 2),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFF9C846),
                borderRadius: BorderRadius.circular(8)),
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))
      ]));
  Widget _buildActionCard(String iconPath, String label,
          {required VoidCallback onTap}) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                Image.asset(iconPath, height: 36),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500))
              ])));
  Widget _buildSectionCard(
          {required String title,
          String? iconPath,
          String? subtitle,
          required Widget child,
          VoidCallback? onTap}) =>
      Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  if (iconPath != null) Image.asset(iconPath, height: 18)
                ]),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 11))
                ],
                const SizedBox(height: 10),
                child
              ],
            ),
          ),
        ),
      );
}
