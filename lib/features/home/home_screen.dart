import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    this.onSavingTarget,
    this.onTransactions,
    this.onExpenseDetails,
  });
  final UkuStore store;
  final VoidCallback onExpense;
  final VoidCallback? onBudget;
  final VoidCallback? onRecap;
  final VoidCallback? onSaving;
  final ValueChanged<Saving>? onSavingTarget;
  final VoidCallback? onTransactions;
  final VoidCallback? onExpenseDetails;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final activities = store.activities;
          final latest = activities.isEmpty ? null : activities.first;
          final featuredSaving = store.latestSaving;
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
                              onTap: onTransactions ??
                                  () => Navigator.push<void>(
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
                                        child: Text(latest?.title ?? '-',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500))),
                                    const SizedBox(width: 8),
                                    Text(
                                        latest == null
                                            ? '-'
                                            : '${latest.type == ActivityType.expense ? '-' : '+'} ${rupiah(latest.amount)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))
                                  ]))),
                          const SizedBox(height: 14),
                          _buildSectionCard(
                              title: 'Nabung',
                              iconPath: 'assets/icons/LoveforMoney.png',
                              onTap: featuredSaving == null
                                  ? onSaving ??
                                      () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SavingScreen(
                                                store: store,
                                              ),
                                            ),
                                          )
                                  : onSavingTarget != null
                                      ? () => onSavingTarget!(
                                            featuredSaving,
                                          )
                                      : () => Navigator.push<void>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SavingDetailScreen(
                                                store: store,
                                                saving: featuredSaving,
                                              ),
                                            ),
                                          ),
                              child: featuredSaving == null
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
                                              Text(featuredSaving.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(featuredSaving.note,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11))
                                            ])),
                                        const SizedBox(width: 8),
                                        Text(
                                            '+ ${rupiah(featuredSaving.current)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ]))),
                          const SizedBox(height: 14),
                          _buildSectionCard(
                              title: 'AI Notifikasi',
                              icon: Icons.auto_awesome,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Grafik Keuangan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _monthLabel(DateTime.now()),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildFinancialChart(store),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                child: Text(
                                                  'Kondisi keuangan saat ini',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color:
                                                      store.remainingBudget >= 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: onExpenseDetails,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Klik Untuk Detail Transaksi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
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
          IconData? icon,
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
                  if (iconPath != null) Image.asset(iconPath, height: 18),
                  if (icon != null)
                    Icon(icon, size: 20, color: const Color(0xFFFF8A00))
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

  Widget _buildFinancialChart(UkuStore store) {
    final expense = store
        .expensesForMonth(DateTime.now())
        .fold<double>(0, (total, item) => total + item.amount);
    final remaining = store.remainingBudget;
    final maxY = [
      store.budget,
      expense,
      remaining,
    ].reduce((first, second) => first > second ? first : second);
    final chartMax = maxY > 0 ? maxY : 1.0;

    return SizedBox(
      height: 116,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: chartMax / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFEDEDED), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, _) => Text(
                  _compactRupiah(value),
                  style: const TextStyle(fontSize: 7, color: Colors.black54),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    value.toInt() == 0 ? 'Pengeluaran' : 'Sisa budget',
                    style: const TextStyle(fontSize: 7),
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            _financialBar(0, expense),
            _financialBar(1, remaining > 0 ? remaining : 0),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _financialBar(int x, double amount) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: amount,
            width: 34,
            color: const Color(0xFF5A9CF8),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );

  String _monthLabel(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _compactRupiah(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    return '${(amount / 1000).round()}k';
  }
}
