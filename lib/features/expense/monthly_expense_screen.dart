import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';

class MonthlyExpenseScreen extends StatefulWidget {
  const MonthlyExpenseScreen({super.key, required this.store, this.onBack});

  final UkuStore store;
  final VoidCallback? onBack;

  @override
  State<MonthlyExpenseScreen> createState() => _MonthlyExpenseScreenState();
}

class _MonthlyExpenseScreenState extends State<MonthlyExpenseScreen> {
  static const _monthNames = [
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
  static const _chartColors = [
    Color(0xFFFAAE36),
    Color(0xFF4F9CF9),
    Color(0xFF54B88A),
    Color(0xFFE87762),
    Color(0xFF9575CD),
    Color(0xFF43A6A1),
    Color(0xFFE5B84B),
  ];

  late DateTime _month;
  Timer? _monthTimer;

  @override
  void initState() {
    super.initState();
    _month = DateTime.now();
    _scheduleMonthRefresh();
  }

  void _scheduleMonthRefresh() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    _monthTimer = Timer(nextMonth.difference(now), () {
      if (!mounted) return;
      setState(() => _month = DateTime.now());
      _scheduleMonthRefresh();
    });
  }

  @override
  void dispose() {
    _monthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final expenses = widget.store.expensesForMonth(_month)
          ..sort((a, b) => a.date.compareTo(b.date));
        final categoryTotals = widget.store.categoryTotals(_month);
        final dailyTotals = <int, double>{};
        for (final expense in expenses) {
          dailyTotals.update(
            expense.date.day,
            (total) => total + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }
        final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
        final dailyMax = dailyTotals.values.isEmpty
            ? 100000.0
            : math
                .max(100000.0, dailyTotals.values.reduce(math.max) * 1.25)
                .toDouble();
        final monthlyTotal = expenses.fold<double>(
          0,
          (total, expense) => total + expense.amount,
        );
        final categoryEntries = categoryTotals.entries.toList();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 12,
                      child: IconButton(
                        tooltip: 'Kembali',
                        onPressed: widget.onBack ??
                            () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFFFAAE36)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 58),
                        child: const Text(
                          'Pengeluaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_month,
                      size: 18, color: Color(0xFFFAAE36)),
                  const SizedBox(width: 7),
                  Text(
                    '${_monthNames[_month.month - 1]} ${_month.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text('${expenses.length} transaksi',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),
              _buildChartCard(
                title: 'Grafik Pengeluaran',
                subtitle: '${_monthNames[_month.month - 1]} ${_month.year}',
                child: expenses.isEmpty
                    ? const _EmptyChartMessage()
                    : SizedBox(
                        height: 190,
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: daysInMonth.toDouble(),
                            minY: 0,
                            maxY: dailyMax,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: dailyMax / 4,
                              getDrawingHorizontalLine: (_) => const FlLine(
                                  color: Color(0xFFEDEDED), strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 38,
                                  getTitlesWidget: (value, _) => Text(
                                    value == 0
                                        ? '0'
                                        : '${(value / 1000).round()}k',
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: math
                                      .max(1, (daysInMonth / 4).floor())
                                      .toDouble(),
                                  getTitlesWidget: (value, _) => Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(value.toInt().toString(),
                                        style: const TextStyle(fontSize: 9)),
                                  ),
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (var day = 1; day <= daysInMonth; day++)
                                    FlSpot(
                                        day.toDouble(), dailyTotals[day] ?? 0),
                                ],
                                isCurved: true,
                                color: const Color(0xFF4F9CF9),
                                barWidth: 2,
                                dotData: FlDotData(
                                  show: dailyTotals.isNotEmpty,
                                  getDotPainter: (spot, _, __, ___) =>
                                      FlDotCirclePainter(
                                    radius: spot.y > 0 ? 3 : 0,
                                    color: const Color(0xFF4F9CF9),
                                    strokeWidth: 0,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF4F9CF9)
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              _buildChartCard(
                title: 'Jenis Pengeluaran',
                subtitle: '${_monthNames[_month.month - 1]} ${_month.year}',
                child: categoryEntries.isEmpty
                    ? const _EmptyChartMessage()
                    : Column(
                        children: [
                          SizedBox(
                            height: 190,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 38,
                                sections: categoryEntries
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final category = entry.value;
                                  final percentage =
                                      category.value / monthlyTotal * 100;
                                  return PieChartSectionData(
                                    value: category.value,
                                    title: '${percentage.round()}%',
                                    radius: 62,
                                    color: _chartColors[
                                        entry.key % _chartColors.length],
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var index = 0;
                              index < categoryEntries.length;
                              index++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: _chartColors[
                                            index % _chartColors.length],
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(categoryEntries[index].key,
                                          style:
                                              const TextStyle(fontSize: 11))),
                                  Text(rupiah(categoryEntries[index].value),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard(
      {required String title,
      required String subtitle,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 190,
      child: Center(
          child: Text('Belum ada pengeluaran bulan ini',
              style: TextStyle(color: Colors.grey, fontSize: 12))),
    );
  }
}
