import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';

const Color primaryColor = Color(0xFF0ABAB5);
const Color textColor = Color(0xFF000000);
const Color secondaryTextColor = Colors.grey;

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitNotifier>().fetchLatestSleepLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep'), foregroundColor: primaryColor),
      body: Consumer<HabitNotifier>(builder: (context, n, _) {
        final log = n.latestSleepLog;
        final text = _format(log);
        final stars = (log?['starCount'] ?? 0) as int;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) =>
                Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber))),
            const Spacer(),
            FilledButton(onPressed: _edit, child: const Text('Log Sleep')),
          ]),
        );
      }),
    );
  }

  String _format(Map<String, dynamic>? log) {
    if (log == null) return 'No sleep logged';
    final bed = _parseTod(log['bedTime'] as String);
    final wake = _parseTod(log['wakeTime'] as String);
    final now = DateTime.now();
    var bdt = DateTime(now.year, now.month, now.day, bed.hour, bed.minute);
    var wdt = DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
    if (!wdt.isAfter(bdt)) wdt = wdt.add(const Duration(days: 1));
    final dur = wdt.difference(bdt);
    final h = dur.inHours, m = dur.inMinutes.remainder(60);
    return '${h}h ${m}m last night';
  }

  Future<void> _edit() async {
    TimeOfDay bed = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay wake = const TimeOfDay(hour: 6, minute: 0);

    final res = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: const Text('Log Your Sleep'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(title: const Text('Bedtime'), subtitle: Text(_hhmm(bed)),
              onTap: () async { final p=await showTimePicker(context: context, initialTime: bed); if(p!=null){ setS(()=>bed=p);} }),
            ListTile(title: const Text('Wake-up Time'), subtitle: Text(_hhmm(wake)),
              onTap: () async { final p=await showTimePicker(context: context, initialTime: wake); if(p!=null){ setS(()=>wake=p);} }),
          ]),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: ()=>Navigator.pop(context, {'bed':bed,'wake':wake}), child: const Text('Save')),
          ],
        );
      }),
    );

    if (res != null) {
      final bedT = res['bed']!, wakeT = res['wake']!;
      final now = DateTime.now();
      var bdt = DateTime(now.year, now.month, now.day, bedT.hour, bedT.minute);
      var wdt = DateTime(now.year, now.month, now.day, wakeT.hour, wakeT.minute);
      if (!wdt.isAfter(bdt)) wdt = wdt.add(const Duration(days: 1));
      final dur = wdt.difference(bdt);
      final stars = _stars(dur);
      await context.read<HabitNotifier>().saveSleepLog(bedTime: bedT, wakeTime: wakeT, starCount: stars);
    }
  }

  int _stars(Duration d){
    final h = d.inHours;
    if(h>10) return 2;
    if(h>=8) return 5;
    if(h>=6) return 4;
    if(h>=5) return 3;
    if(h>=3) return 2;
    if(h>0)  return 1;
    return 0;
  }

  String _hhmm(TimeOfDay t)=>'${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  TimeOfDay _parseTod(String s){ final p=s.split(':'); return TimeOfDay(hour:int.parse(p[0]), minute:int.parse(p[1])); }
}
