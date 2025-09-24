import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_point.dart';
import 'chart_style.dart';
import 'nice_scale.dart';

class TrendLineChart extends StatelessWidget {
  final List<ChartPoint> data;
  final String unit;            // 'ชม.' / 'นาที' / 'แก้ว'
  final double? goal;           // เส้นเป้าหมาย
  final int targetXTicks;
  final bool curved;            // ✅ new: true=เส้นโค้ง, false=เส้นตรง

  const TrendLineChart({
    super.key,
    required this.data,
    required this.unit,
    this.goal,
    this.targetXTicks = 6,
    this.curved = true,         // ค่า default สำหรับ Sleep/Exercise
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('ไม่มีข้อมูล'));

    final start = DateTime(data.first.day.year, data.first.day.month, data.first.day.day);
    double toX(DateTime d) => DateTime(d.year, d.month, d.day).difference(start).inDays.toDouble();
    String ddmm(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    final xs = data.map((p) => toX(p.day)).toList(growable: false);
    final ys = data.map((p) => p.value).toList(growable: false);

    final nice = niceScale(ys, targetTicks: 5);
    final maxY = nice.maxY == 0 ? 1.0 : nice.maxY;
    final yInterval = nice.interval;
    final maxX = xs.last;

    final lineColor = ChartStyle.seriesColor(context);
    final spots = [for (final p in data) FlSpot(toX(p.day), p.value)];
    final bottomInterval = (data.length / targetXTicks).clamp(1, 999).toDouble();

    final todayX = toX(DateTime.now());
    final showToday = todayX >= 0 && todayX <= maxX;

    return LineChart(
      LineChartData(
        minX: 0, maxX: maxX, minY: 0, maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (_) => FlLine(
            color: ChartStyle.gridColor(context), strokeWidth: 1, dashArray: [5, 5],
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: ChartStyle.gridColor(context), strokeWidth: 1, dashArray: [4, 6],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                v % yInterval == 0
                    ? (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1))
                    : '',
                style: ChartStyle.axisLabel(context),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              getTitlesWidget: (x, _) {
                final d = start.add(Duration(days: x.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(ddmm(d), style: ChartStyle.axisLabel(context)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            // แทน tooltipRoundedRadius: 8, ด้วยบรรทัดนี้
            tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (items) => items.map((it) {
              final d = start.add(Duration(days: it.x.toInt()));
              final y = it.y % 1 == 0 ? it.y.toInt().toString() : it.y.toStringAsFixed(1);
              return LineTooltipItem(
                '${ddmm(d)}\n$y $unit',
                ChartStyle.tooltipText(context),
              );
            }).toList(),
          ),
        ),

        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (goal != null)
              HorizontalLine(
                y: goal!,
                color: lineColor.withValues(alpha: .7),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'เป้าหมาย ${goal!.toStringAsFixed(0)} $unit',
                  style: ChartStyle.axisLabel(context),
                  alignment: Alignment.topRight,
                ),
              ),
          ],
          verticalLines: [
            if (showToday)
              VerticalLine(
                x: todayX,
                color: lineColor.withValues(alpha: .85),
                strokeWidth: 1,
                dashArray: [2, 3],
                label: VerticalLineLabel(
                  show: true,
                  labelResolver: (_) => 'วันนี้',
                  alignment: Alignment.bottomRight,
                  style: ChartStyle.axisLabel(context),
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            color: lineColor,
            isCurved: curved,      // ✅ ใช้โค้ง/ตรงตามที่ส่งมา
            barWidth: 3,
            isStrokeCapRound: true,
            spots: spots,
            dotData: FlDotData(show: data.length <= 21),
            belowBarData: BarAreaData(show: true, gradient: ChartStyle.areaGradient(context)),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
