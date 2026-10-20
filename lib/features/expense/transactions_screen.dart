import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, required this.store, this.onBack});

  final UkuStore store;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final activities = store.activities;
        final latestDate =
            activities.isEmpty ? DateTime.now() : activities.first.date;

        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 12,
                      child: IconButton(
                        tooltip: 'Kembali',
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFFFAAE36)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 58),
                        child: const Text(
                          'Riwayat Transaksi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: activities.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: activities.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                _formatDate(latestDate),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return _ActivityDetails(
                            activity: activities[index - 1],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityDetails extends StatelessWidget {
  const _ActivityDetails({required this.activity});

  final FinancialActivity activity;

  @override
  Widget build(BuildContext context) {
    final color = switch (activity.type) {
      ActivityType.expense => const Color(0xFFE65353),
      ActivityType.income => const Color(0xFF278A5B),
      ActivityType.saving => const Color(0xFFFAAE36),
    };
    final icon = switch (activity.type) {
      ActivityType.expense => Icons.payments_outlined,
      ActivityType.income => Icons.south_west,
      ActivityType.saving => Icons.savings_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${activity.typeLabel} · ${_formatDate(activity.date)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
                if (activity.description.isNotEmpty &&
                    activity.description != activity.title)
                  Text(
                    activity.description,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                if (activity.method.isNotEmpty)
                  Text(
                    'Metode: ${activity.method}',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                if (activity.location.isNotEmpty)
                  Text(
                    'Lokasi: ${activity.location}',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${activity.type == ActivityType.expense ? '-' : '+'} ${rupiah(activity.amount)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
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
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}