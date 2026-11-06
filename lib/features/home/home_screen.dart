import 'package:flutter/material.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/expense/recap_screen.dart';
import 'package:uku_app/features/savings/saving_detail_screen.dart';
import 'package:uku_app/features/savings/saving_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({
    super.key,
    required this.store,
    required this.onExpense,
    this.userName = 'User',
    this.onExpenseCategory,
    this.onRecap,
    this.onSaving,
    this.onSavingTarget,
    this.onExpenseDetails,
  });

  final UkuStore store;
  final String userName;
  final VoidCallback onExpense;
  final ValueChanged<String>? onExpenseCategory;
  final VoidCallback? onRecap;
  final VoidCallback? onSaving;
  final ValueChanged<Saving>? onSavingTarget;
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
        final currentMonthExpense = store
            .expensesForMonth(now)
            .fold<double>(0, (total, expense) => total + expense.amount);
        final spentPercentage = store.hasBudgetForMonth(now) && store.budget > 0
            ? (currentMonthExpense / store.budget * 100)
                .clamp(0, 999)
                .toDouble()
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $userName 👋',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Kelola keuangan harianmu dengan bijak',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                        onTap: null,
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
                            ],
                          ),
                        ),
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
                              'assets/icons/Spiral Bound Booklet.png',
                              'Rekap Aktivitas',
                              'Lihat riwayat aktivitas',
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
                              'assets/icons/Love for Money.png',
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
                        onTap: onExpenseDetails,
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
                                        color:
                                            latest.type == ActivityType.expense
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
                        iconPath: 'assets/icons/Love for Money.png',
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
                                        Expanded(
                                          child: Text(
                                            'Terkumpul: ${rupiah(featuredSaving.current)}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Target: ${rupiah(featuredSaving.target)}',
                                            maxLines: 1,
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
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
      (
        label: 'Makan',
        category: 'Makanan & Minuman',
        icon: 'assets/icons/Restaurant.png'
      ),
      (
        label: 'Transport',
        category: 'Transportasi',
        icon: 'assets/icons/Public Transportation.png'
      ),
      (
        label: 'Belanja',
        category: 'Belanja',
        icon: 'assets/icons/Shopping Bag.png'
      ),
      (
        label: 'Hiburan',
        category: 'Hiburan',
        icon: 'assets/icons/3D Glasses.png'
      ),
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
                          const SizedBox(height: 6),
                          const Text(
                            'Catat Pengeluaran',
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
                  ],
                ),
                const SizedBox(height: 14),
                // Quick Category Chips
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    final now = DateTime.now();
    final hasBudget = store.hasBudgetForMonth(now) && store.budget > 0;
    final monthExpense = store
        .expensesForMonth(now)
        .fold<double>(0, (total, expense) => total + expense.amount);
    final isOverBudget = hasBudget && monthExpense > store.budget;
    final isNearBudget = hasBudget && spentPercentage >= 80 && !isOverBudget;
    final statusColor = isOverBudget
        ? const Color(0xFFD84315)
        : isNearBudget
            ? const Color(0xFFE06B00)
            : const Color(0xFF2E7D32);
    final headline = !hasBudget
        ? 'Atur budget untuk memantau pengeluaranmu.'
        : isOverBudget
            ? 'Pengeluaranmu telah melewati batas!'
            : isNearBudget
                ? 'Pengeluaranmu hampir melewati batas!'
                : 'Pengeluaranmu masih dalam batas aman.';
    final analysis = !hasBudget
        ? 'Total pengeluaranmu bulan ini ${rupiah(monthExpense)}. Atur budget bulanan agar AIKu dapat membantu memantau kondisi keuanganmu.'
        : isOverBudget
            ? 'Pengeluaranmu sudah melebihi budget sebesar ${rupiah((monthExpense - store.budget).toDouble())}. Tinjau kembali pengeluaran yang tidak mendesak agar kondisi keuangan tetap terkendali.'
            : isNearBudget
                ? 'Pengeluaranmu sudah mencapai ${spentPercentage.toStringAsFixed(1)}% dari budget bulanan. Dengan sisa budget ${rupiah(store.remainingBudget)}, sebaiknya kurangi pengeluaran yang tidak mendesak agar anggaranmu tetap terkendali.'
                : 'Pengeluaranmu baru mencapai ${spentPercentage.toStringAsFixed(1)}% dari budget bulanan. Sisa budget ${rupiah(store.remainingBudget)}; pertahankan kebiasaan belanja sesuai prioritas.';
    final suggestions = !hasBudget
        ? const [
            'Atur budget bulananmu.',
            'Catat pengeluaran secara rutin.',
            'Tinjau kembali pengeluaran tiap minggu.',
          ]
        : [
            'Prioritaskan kebutuhan utama.',
            isOverBudget || isNearBudget
                ? 'Kurangi pembelian yang tidak direncanakan.'
                : 'Sisihkan sisa budget untuk kebutuhan penting.',
            'Pantau pengeluaran harianmu.',
          ];
    final analysisAction = onExpenseDetails ??
        () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => RecapScreen(store: store),
              ),
            );

    return Container(
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
          const Text(
            'AI Financial Assistant',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                hasBudget && !isOverBudget && !isNearBudget
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            rupiah(monthExpense),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total pengeluaran bulan ini',
            style: TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hasBudget ? (spentPercentage / 100).clamp(0, 1) : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Budget: ${hasBudget ? rupiah(store.budget) : 'Belum diatur'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ),
              if (hasBudget) ...[
                const SizedBox(width: 8),
                Text(
                  '${spentPercentage.toStringAsFixed(1)}% terpakai',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          const Text(
            'Analisis AI',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            analysis,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 17, color: Color(0xFFFF8A00)),
                    SizedBox(width: 7),
                    Text(
                      'Saran untukmu',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (final suggestion in suggestions)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: analysisAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAAE36),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Lihat Analisis Keuangan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(
                      fontSize: 14,
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
}
