import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_point.dart';
import 'chart_style.dart';
import 'nice_scale.dart';
import '../l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context);
    if (data.isEmpty) return Center(child: Text(t.noDataAvailable));

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
    // ปรับ interval ให้เหมาะสมกับจำนวนข้อมูล เพื่อป้องกันวันที่ซ้อนกัน
    final bottomInterval = data.length <= 7 
        ? 1.0 // ถ้าข้อมูลน้อย แสดงทุกวัน
        : data.length <= 14 
            ? 2.0 // แสดงเว้นวัน
            : (data.length / 4).clamp(2, 999).toDouble(); // แสดง 4-5 วันที่

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
              reservedSize: 50,
              getTitlesWidget: (v, _) => Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  v % yInterval == 0
                      ? (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1))
                      : '',
                  style: ChartStyle.axisLabel(context),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              reservedSize: 36,
              getTitlesWidget: (x, _) {
                // แสดงเฉพาะวันที่ที่ตรงกับ interval เพื่อป้องกันการซ้อนกัน
                if (x % bottomInterval != 0) return const SizedBox.shrink();
                
                final d = start.add(Duration(days: x.toInt()));
                return Container(
                  width: 50, // กำหนดความกว้างให้ชัดเจน
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ddmm(d), 
                    style: ChartStyle.axisLabel(context).copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (items) => items.map((it) {
              final d = start.add(Duration(days: it.x.toInt()));
              final y = it.y % 1 == 0 ? it.y.toInt().toString() : it.y.toStringAsFixed(1);
              return LineTooltipItem('${ddmm(d)}\n$y $unit', ChartStyle.tooltipText(context));
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
                  labelResolver: (_) => '${t.goalLabel} ${goal!.toStringAsFixed(0)} $unit',
                  style: ChartStyle.axisLabel(context),
                  alignment: Alignment.topLeft,
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
                  show: false, // ซ่อน label "วันนี้" เพื่อไม่ให้อยู่นอก card
                  labelResolver: (_) => '',
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
