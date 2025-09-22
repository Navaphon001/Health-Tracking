import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../charts/chart_point.dart';
import '../charts/trend_line_chart.dart';
// ❌ ไม่ต้องใช้แล้ว: import '../charts/trend_bar_chart.dart';
import '../services/habit_local_repository.dart';
import '../providers/habit_notifier.dart';

class HealthTrendsScreen extends StatelessWidget {
  final HabitLocalRepository repo;
  final int days;

  const HealthTrendsScreen({super.key, required this.repo, this.days = 14});

  @override
  Widget build(BuildContext context) {
    final waterGoal = context.select<HabitNotifier, int>((n) => n.dailyWaterGoal);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Trends')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SectionCard(
            title: 'Sleep (ชั่วโมง/วัน)',
            future: repo.fetchSleepHoursSeries(days: days),
            childBuilder: (data) => TrendLineChart(
              data: data,
              unit: 'ชม.',
              goal: 8,
              curved: true,     // เส้นโค้ง
            ),
          ),
          SectionCard(
            title: 'Water (แก้ว/วัน)',
            future: repo.fetchWaterCountSeries(days: days),
            childBuilder: (data) => TrendLineChart(
              data: data,
              unit: 'แก้ว',
              goal: waterGoal.toDouble(),
              curved: false,    // ✅ เส้นตรงรายวัน (เหมาะกับ count/วัน)
            ),
          ),
          SectionCard(
            title: 'Exercise (นาที/วัน)',
            future: repo.fetchExerciseDurationSeries(days: days),
            childBuilder: (data) => TrendLineChart(
              data: data,
              unit: 'นาที',
              goal: 30,
              curved: true,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Future<List<ChartPoint>> future;
  final Widget Function(List<ChartPoint>) childBuilder;

  const SectionCard({
    super.key,
    required this.title,
    required this.future,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: FutureBuilder<List<ChartPoint>>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('ผิดพลาด: ${snap.error}'));
                  }
                  final data = snap.data ?? const <ChartPoint>[];
                  if (data.isEmpty) return const Center(child: Text('ยังไม่มีข้อมูล'));
                  return childBuilder(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}