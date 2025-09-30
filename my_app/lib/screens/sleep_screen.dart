import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/habit_notifier.dart';
import '../services/alarm_service.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepQualityChart extends StatelessWidget {
  final Duration duration;
  final double size;

  const _SleepQualityChart({required this.duration, required this.size});

  @override
  Widget build(BuildContext context) {
    final totalHours = duration.inMinutes / 60.0;
    // Map hours to a 0..1 quality value assuming 0..10 hours scale
    final quality = (totalHours / 10.0).clamp(0.0, 1.0);
    final percent = (quality * 100).round();

  // texts: use existing localization for sleep hours label; Quality isn't defined so use literal
  final qualityText = 'Quality';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(quality: quality),
              ),
              // Inner texts
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(qualityText, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    '$percent',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  // show only percent sign as requested
                  Text('%', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // External duration texts
        Text('${totalHours.toStringAsFixed(1)} h', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double quality; // 0..1
  _RingPainter({required this.quality});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.22; // narrow ring

    final bgPaint = Paint()
      ..color = AppColors.chartGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * quality,
        colors: [AppColors.chartPrimary, AppColors.chartSecondary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
                          // final star = _stars(d);
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweep = 2 * math.pi * quality;
    // Avoid a visible seam at the arc join by drawing a full circle when quality is nearly 1.0
    if ((quality - 1.0).abs() < 0.002) {
      // draw full circle with fgPaint
      canvas.drawCircle(center, radius - strokeWidth / 2, fgPaint);
    } else {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), -math.pi / 2, sweep, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.quality != quality;
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _bed = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wake = const TimeOfDay(hour: 6, minute: 0);
  bool _bedEnabled = true;
  bool _wakeEnabled = true;

  @override
  void initState() {
    super.initState();
    // preload ค่าล่าสุด (ถ้ามี)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final n = context.read<HabitNotifier>();
      await n.fetchLatestSleepLog();
      if (!mounted) return;
      final log = n.latestSleepLog;
      if (log != null) {
        setState(() {
          _bed = _parseTod(log['bedTime'] as String);
          _wake = _parseTod(log['wakeTime'] as String);
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dur = _calcDuration(_bed, _wake);

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.sleep,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Compact rounded pie chart (quality) + duration labels
            Center(
              child: _SleepQualityChart(
                duration: dur,
                size: 180,
              ),
            ),

            const SizedBox(height: 24),

            // เลือกเวลานอน
            _ScheduleCard(
              title: t.bedtime,
              time: _bed,
              icon: Icons.nightlight_round,
              enabled: _bedEnabled,
              onTimeChanged: (picked) {
                if (!mounted) return;
                setState(() => _bed = picked);
              },
              onEnabledChanged: (v) async {
                if (!mounted) return;
                setState(() => _bedEnabled = v);
                if (v) {
                  // schedule alarm after 10 seconds for demo
                  await AlarmService.scheduleAlarmInSeconds(100, 10);
                } else {
                  await AlarmService.cancel(100);
                }
              },
            ),
            const SizedBox(height: 12),

            // เลือกเวลาตื่น
            _ScheduleCard(
              title: t.wakeUpTime,
              time: _wake,
              icon: Icons.wb_sunny,
              enabled: _wakeEnabled,
              onTimeChanged: (picked) {
                if (!mounted) return;
                setState(() => _wake = picked);
              },
              onEnabledChanged: (v) async {
                if (!mounted) return;
                setState(() => _wakeEnabled = v);
                if (v) {
                  await AlarmService.scheduleAlarmInSeconds(101, 10);
                } else {
                  await AlarmService.cancel(101);
                }
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------

  Duration _calcDuration(TimeOfDay bed, TimeOfDay wake) {
    final now = DateTime.now();
    var bdt = DateTime(now.year, now.month, now.day, bed.hour, bed.minute);
    var wdt = DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
    if (!wdt.isAfter(bdt)) wdt = wdt.add(const Duration(days: 1)); // กรณีข้ามวัน
    return wdt.difference(bdt);
  }

  // (removed unused _formatDuration)

  // _stars removed: it was used only by the removed Log Sleep button

  TimeOfDay _parseTod(String s) {
    final p = s.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }
}
class _ScheduleCard extends StatefulWidget {
  final String title;
  final TimeOfDay time;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;

  const _ScheduleCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.enabled,
  required this.onEnabledChanged,
  this.onTimeChanged,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  String _timeUntilText(TimeOfDay t) {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    if (!dt.isAfter(now)) dt = dt.add(const Duration(days: 1));
    final diff = dt.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return 'in ${hours}hours ${minutes}minutes';
    return 'in ${minutes}minutes';
  }

  @override
  Widget build(BuildContext context) {
    final timeText = '${widget.time.hour.toString().padLeft(2,'0')}:${widget.time.minute.toString().padLeft(2,'0')}';
    return GestureDetector(
      onTap: () async {
        if (widget.onTimeChanged == null) return;
        DateTime initial = DateTime.now();
        initial = DateTime(initial.year, initial.month, initial.day, widget.time.hour, widget.time.minute);
        DateTime temp = initial;
        final picked = await showModalBottomSheet<DateTime>(
          context: context,
          builder: (ctx) {
            return SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: initial,
                      onDateTimeChanged: (dt) => temp = dt,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(AppLocalizations.of(context).cancel),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 18),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(temp),
                          child: Text(AppLocalizations.of(context).done),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        if (picked != null) {
          final tod = TimeOfDay(hour: picked.hour, minute: picked.minute);
          widget.onTimeChanged!(tod);
        }
      },
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Icon(widget.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(timeText, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_timeUntilText(widget.time), style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _enabled,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _enabled = v);
              widget.onEnabledChanged(v);
            },
          ),
        ],
      ),
      ),
    );
  }
}
