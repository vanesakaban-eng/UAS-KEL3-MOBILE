import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/uku_store.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key, required this.store});
  final UkuStore store;

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  DateTime month = DateTime.now();

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFA9D2B))), child: child!),
    );
    if (picked != null) setState(() => month = picked);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.store.expensesForMonth(month);
    final cats = widget.store.categoryTotals(month);
    final maxY = ([100000.0, ...list.map((e) => e.amount)]..sort()).last * 1.25;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Rekap Aktivitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            OutlinedButton.icon(onPressed: _pickMonth, icon: const Icon(Icons.calendar_month, size: 17, color: Color(0xFFFA9D2B)), label: Text('${month.month.toString().padLeft(2, '0')}/${month.year}', style: const TextStyle(fontSize: 11, color: Colors.black))),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Grafik Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Data nyata dari pengeluaran yang kamu simpan', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 18),
              SizedBox(height: 220, child: BarChart(BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (value, meta) => Text('${(value / 1000).round()}k', style: const TextStyle(fontSize: 9)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    final day = value.toInt();
                    return Padding(padding: const EdgeInsets.only(top: 5), child: Text(day.toString(), style: const TextStyle(fontSize: 9)));
                  })),
                ),
                barGroups: list.asMap().entries.map((entry) {
                  final e = entry.value;
                  return BarChartGroupData(x: e.date.day, barRods: [BarChartRodData(toY: e.amount, width: 16, borderRadius: BorderRadius.circular(4), color: const Color(0xFFFA9D2B))]);
                }).toList(),
              ))),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Grafik Berdasarkan Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              SizedBox(height: 220, child: cats.isEmpty ? const Center(child: Text('Belum ada data untuk bulan ini', style: TextStyle(color: Colors.grey))) : PieChart(PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 42,
                sections: cats.entries.map((entry) {
                  final total = cats.values.fold(0.0, (a, b) => a + b);
                  return PieChartSectionData(value: entry.value, title: '${(entry.value / total * 100).round()}%', radius: 72, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold));
                }).toList(),
              ))),
              const SizedBox(height: 8),
              ...cats.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 11)), Text(rupiah(e.value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]))),
            ]),
          ),
        ],
      ),
    );
  }
}
