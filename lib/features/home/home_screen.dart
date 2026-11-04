import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/ai/ai_screen.dart';
import 'package:uku_app/features/expense/recap_screen.dart';
import 'package:uku_app/features/expense/transactions_screen.dart';
import 'package:uku_app/features/savings/saving_detail_screen.dart';
import 'package:uku_app/features/savings/saving_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({
    super.key,
    required this.store,
    required this.onExpense,
    this.onExpenseCategory,
    this.onBudget,
    this.onRecap,
    this.onSaving,
    this.onSavingTarget,
    this.onTransactions,
    this.onExpenseDetails,
  });

  final UkuStore store;
  final VoidCallback onExpense;
  final ValueChanged<String>? onExpenseCategory;
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

        final now = DateTime.now();
        final totalDaysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        final daysRemaining = (totalDaysInMonth - now.day + 1).clamp(1, 31);
        final dailySafeToSpend = store.remainingBudget > 0
            ? (store.remainingBudget / daysRemaining)
            : 0.0;
        final spentPercentage = store.budget > 0
            ? (store.totalExpense / store.budget * 100).clamp(0, 999).toDouble()
            : 0.0;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== 1. TOP HEADER BANNER ====================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFAAE36), Color(0xFFF8991D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, Sobat UKu 👋',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Kelola keuangan harianmu dengan bijak',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: store.isOverBudget
                                  ? const Color(0xFFE53935)
                                  : (spentPercentage > 80
                                      ? const Color(0xFFEF6C00)
                                      : const Color(0xFF2E7D32)),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  store.isOverBudget
                                      ? Icons.warning_amber_rounded
                                      : (spentPercentage > 80
                                          ? Icons.error_outline_rounded
                                          : Icons.check_circle_outline_rounded),
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  store.isOverBudget
                                      ? 'Over Budget'
                                      : (spentPercentage > 80
                                          ? 'Waspada'
                                          : 'Budget Aman'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sisa Budget Bulan Ini',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onBudget,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                rupiah(store.remainingBudget),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: store.isOverBudget
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit_note_rounded,
                                size: 18,
                                color: Color(0xFFFAAE36),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Jatah Belanja Aman Harian (Daily Hook)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                store.isOverBudget
                                    ? 'Pengeluaran telah melebihi target anggaran!'
                                    : 'Jatah belanja aman: ${rupiah(dailySafeToSpend)} / hari (sisa $daysRemaining hari)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildInfoBox(
                            'Pengeluaran',
                            rupiah(store.totalExpense),
                            Icons.arrow_upward_rounded,
                            const Color(0xFFFFEAEA),
                            const Color(0xFFD32F2F),
                          ),
                          const SizedBox(width: 10),
                          _buildInfoBox(
                            'Pemasukkan',
                            rupiah(store.income),
                            Icons.arrow_downward_rounded,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==================== 2. MAIN BODY CONTENT ====================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----- THE HERO ACTION: CATAT PENGELUARAN (THE VISUAL HOOK) -----
                      _buildHeroExpenseCard(context),

                      const SizedBox(height: 16),

                      // Quick Action Shortcuts (Rekap & Nabung)
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'assets/icons/PaymentHistory.png',
                              'Rekap Aktivitas',
                              'Grafik & Analisis',
                              onTap: onRecap ??
                                  () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecapScreen(
                                            store: store,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              'assets/icons/LoveforMoney.png',
                              'Nabung',
                              'Target Impian',
                              onTap: onSaving ??
                                  () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SavingScreen(
                                            store: store,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ----- AI SMART INSIGHT CARD -----
                      _buildAiInsightCard(context, spentPercentage),

                      const SizedBox(height: 18),

                      // ----- TRANSAKSI TERAKHIR -----
                      _buildSectionCard(
                        title: 'Transaksi Terakhir',
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
                        child: latest == null
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Belum ada catatan transaksi.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFD180),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: latest.iconPath != null
                                          ? Image.asset(
                                              latest.iconPath!,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.receipt_long,
                                                size: 20,
                                                color: Color(0xFFFAAE36),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.receipt_long,
                                              size: 20,
                                              color: Color(0xFFFAAE36),
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            latest.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            latest.description.isNotEmpty
                                                ? latest.description
                                                : latest.typeLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${latest.type == ActivityType.expense ? '-' : '+'} ${rupiah(latest.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: latest.type ==
                                                ActivityType.expense
                                            ? const Color(0xFFD32F2F)
                                            : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 18),

                      // ----- TARGET TABUNGAN (COMPACT & MODERN PROGRESS) -----
                      _buildSectionCard(
                        title: 'Target Tabungan',
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
                                ? () => onSavingTarget!(featuredSaving)
                                : () => Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SavingDetailScreen(
                                          store: store,
                                          saving: featuredSaving,
                                        ),
                                      ),
                                    ),
                        child: featuredSaving == null
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Belum ada target tabungan dibuat.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            featuredSaving.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(featuredSaving.progress * 100).toInt()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFAAE36),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: featuredSaving.progress,
                                        minHeight: 8,
                                        backgroundColor: Colors.black12,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFAAE36),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Terkumpul: ${rupiah(featuredSaving.current)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Target: ${rupiah(featuredSaving.target)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== HERO ACTION: CATAT PENGELUARAN ====================
  Widget _buildHeroExpenseCard(BuildContext context) {
    const quickCategories = [
      (label: 'Makan', category: 'Makanan & Minuman', icon: 'assets/icons/Restaurant.png'),
      (label: 'Transport', category: 'Transportasi', icon: 'assets/icons/Public Transportation.png'),
      (label: 'Belanja', category: 'Belanja', icon: 'assets/icons/Shopping Bag.png'),
      (label: 'Hiburan', category: 'Hiburan', icon: 'assets/icons/3D Glasses.png'),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFA9D2B), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A00).withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onExpense,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Main Plus Button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'CATAT INSTAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Catat Pengeluaran Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tap untuk catat atau pilih kategori cepat di bawah',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Eye-Catching Round Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFFFF7A00),
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Quick Category Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      for (final item in quickCategories)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (onExpenseCategory != null) {
                                onExpenseCategory!(item.category);
                              } else {
                                onExpense();
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      item.icon,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.category,
                                        size: 18,
                                        color: Color(0xFFFAAE36),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Plus more chip
                      Expanded(
                        child: InkWell(
                          onTap: onExpense,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Center(
                                    child: Icon(
                                      Icons.grid_view_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Semua',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== AIKU SMART INSIGHT CARD ====================
  Widget _buildAiInsightCard(BuildContext context, double spentPercentage) {
    String aiMessage;
    Color statusColor;

    if (store.isOverBudget) {
      aiMessage =
          'Pengeluaranmu telah melampaui budget sebesar ${rupiah(store.remainingBudget.abs())}. Disarankan menahan belanja tersier hingga akhir bulan.';
      statusColor = const Color(0xFFE53935);
    } else if (spentPercentage > 80) {
      aiMessage =
          'Kamu sudah memakai ${spentPercentage.toStringAsFixed(0)}% dari anggaranmu. Perketat pengeluaran agar saldo cukup sampai akhir bulan.';
      statusColor = const Color(0xFFEF6C00);
    } else {
      aiMessage =
          'Kondisi keuanganmu bulan ini sangat sehat! Pengeluaran baru ${spentPercentage.toStringAsFixed(0)}% dari total anggaran.';
      statusColor = const Color(0xFF2E7D32);
    }

    return _buildSectionCard(
      title: 'AIKu Smart Advisor',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              border: Border.all(color: const Color(0xFFFFE0B2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tips_and_updates_rounded,
                        size: 20,
                        color: Color(0xFFFAAE36),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Insight Pengeluaran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            aiMessage,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFFFE0B2)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bulan: ${_monthLabel(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.isOverBudget ? 'Over Budget' : 'Terkontrol',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFinancialChart(store),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExpenseDetails,
                  icon: const Icon(Icons.bar_chart_rounded, size: 16),
                  label: const Text('Detail Pengeluaran'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiScreen(store: store),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Tanya AIKu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFAAE36),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE WIDGETS ====================
  Widget _buildInfoBox(
    String label,
    String value,
    IconData icon,
    Color bgIconColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String iconPath,
    String label,
    String subLabel, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? iconPath,
    IconData? icon,
    String? subtitle,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (iconPath != null) Image.asset(iconPath, height: 18),
                  if (icon != null)
                    Icon(icon, size: 20, color: const Color(0xFFFF8A00)),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

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
      height: 110,
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
            _financialBar(0, expense, const Color(0xFFFF7A00)),
            _financialBar(1, remaining > 0 ? remaining : 0, const Color(0xFF43A047)),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _financialBar(int x, double amount, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: amount,
            width: 32,
            color: color,
            borderRadius: BorderRadius.circular(6),
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
