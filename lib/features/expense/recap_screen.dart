import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/widgets/app_back_button.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key, required this.store, this.onBack});

  final UkuStore store;
  final VoidCallback? onBack;

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
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

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final activities = widget.store.activities;
    if (activities.isEmpty) {
      _month = DateTime.now();
      return;
    }

    final latestActivity = activities.first;
    _month = DateTime(latestActivity.date.year, latestActivity.date.month);
  }

  Future<void> _pickMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        var selectedYear = _month.year;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Bulan & Tahun'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: 'Tahun sebelumnya',
                          onPressed: selectedYear > 2020
                              ? () => setDialogState(() => selectedYear--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '$selectedYear',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tahun berikutnya',
                          onPressed: selectedYear < 2035
                              ? () => setDialogState(() => selectedYear++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var month = 0; month < _monthNames.length; month++)
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(
                              DateTime(selectedYear, month + 1),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF292929),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: Text(
                              _monthNames[month],
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() => _month = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final expenses = widget.store.expensesForMonth(_month)
          ..sort((a, b) => b.date.compareTo(a.date));
        final activities = widget.store.activitiesForMonth(_month);
        final dailyTotals = <int, double>{};
        for (final expense in expenses) {
          dailyTotals.update(
            expense.date.day,
            (total) => total + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }
        final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
        final dailyMax = dailyTotals.isEmpty
            ? 100000.0
            : math
                .max(100000.0, dailyTotals.values.reduce(math.max) * 1.25)
                .toDouble();
        final monthLabel = '${_monthNames[_month.month - 1]}, ${_month.year}';

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
                      child: AppBackButton(
                        onPressed: widget.onBack ??
                            () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 58),
                        child: const Text(
                          'Rekap Aktivitas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Pilih Bulan & Tahun',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _pickMonth,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            monthLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const Icon(Icons.calendar_month,
                            size: 18, color: Color(0xFFFAAE36)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildChartCard(
                title: 'Grafik Pengeluaran',
                subtitle: monthLabel,
                child: expenses.isEmpty
                    ? const SizedBox(
                        height: 190,
                        child: Center(
                          child: Text(
                            'Belum ada pengeluaran di bulan ini',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      )
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
                                color: Color(0xFFEDEDED),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
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
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (var day = 1; day <= daysInMonth; day++)
                                    FlSpot(
                                      day.toDouble(),
                                      dailyTotals[day] ?? 0,
                                    ),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Riwayat Pengeluaran',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${activities.length} aktivitas',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat aktivitas',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                )
              else
                for (final activity in activities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${activity.typeLabel} · ${activity.date.day} ${_monthNames[activity.date.month - 1]} ${activity.date.year}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${activity.type == ActivityType.expense ? '-' : '+'} ${rupiah(activity.amount)}',
                            style: TextStyle(
                              color: activity.type == ActivityType.expense
                                  ? Color(0xFFE65353)
                                  : Color(0xFF278A5B),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
