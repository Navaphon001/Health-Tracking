import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';
import '../theme/app_colors.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _bed = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wake = const TimeOfDay(hour: 6, minute: 0);

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
    final dur = _calcDuration(_bed, _wake);
    final stars = _stars(dur);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sleep'),
        foregroundColor: AppColors.primary,
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/settings'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // สรุปชั่วโมงและดาว (อัปเดตทันทีเมื่อเลือกเวลา)
            Text(_formatDuration(dur),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber),
              ),
            ),

            const SizedBox(height: 24),

            // เลือกเวลานอน
            _TimeTile(
              title: 'Bedtime',
              value: _hhmm(_bed),
              icon: Icons.nightlight_round,
              onTap: () async {
                final picked = await _pickTime(context, _bed);
                if (!mounted) return;
                if (picked != null) setState(() => _bed = picked);
              },
            ),
            const SizedBox(height: 12),

            // เลือกเวลาตื่น
            _TimeTile(
              title: 'Wake-up Time',
              value: _hhmm(_wake),
              icon: Icons.wb_sunny,
              onTap: () async {
                final picked = await _pickTime(context, _wake);
                if (!mounted) return;
                if (picked != null) setState(() => _wake = picked);
              },
            ),

            const Spacer(),

            // บันทึก
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.gradientLightEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final n = context.read<HabitNotifier>();
                    final d = _calcDuration(_bed, _wake);
                    final star = _stars(d);
                    await n.saveSleepLog(bedTime: _bed, wakeTime: _wake, starCount: star);
                    if (!mounted) return;
                    // SnackBar จะมาเองจาก callback ใน Notifier (ถ้าตั้งไว้แล้ว)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log Sleep',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Future<TimeOfDay?> _pickTime(BuildContext ctx, TimeOfDay initial) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input, // พิมพ์ได้
      builder: (context, child) {
        // บังคับ 24 ชั่วโมง
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    return picked;
  }

  Duration _calcDuration(TimeOfDay bed, TimeOfDay wake) {
    final now = DateTime.now();
    var bdt = DateTime(now.year, now.month, now.day, bed.hour, bed.minute);
    var wdt = DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
    if (!wdt.isAfter(bdt)) wdt = wdt.add(const Duration(days: 1)); // กรณีข้ามวัน
    return wdt.difference(bdt);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours, m = d.inMinutes.remainder(60);
    return '${h}h ${m}m last night';
  }

  int _stars(Duration d) {
    final h = d.inHours;
    if (h > 10) return 2;
    if (h >= 8) return 5;
    if (h >= 6) return 4;
    if (h >= 5) return 3;
    if (h >= 3) return 2;
    if (h > 0)  return 1;
    return 0;
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  TimeOfDay _parseTod(String s) {
    final p = s.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }
}

class _TimeTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}
