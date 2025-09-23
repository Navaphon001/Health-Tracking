import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ใช้ CupertinoTimerPicker ใน dialog
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';
import '../models/exercise_activity.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = context.read<HabitNotifier>();
      if (n.exerciseActivities.isEmpty) {
      n.fetchExerciseActivities();
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(t.exercise, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/settings'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addOrEdit, child: const Icon(Icons.add)),
      body: Consumer<HabitNotifier>(builder: (context, n, _) {
        final list = n.exerciseActivities;
        if (list.isEmpty) {
          return Center(
            child: Text(t.noActivitiesYet, style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        return SingleChildScrollView(
          child: ExpansionPanelList.radio(
            children: list.map((a) => ExpansionPanelRadio(
              value: a.id,
              headerBuilder: (_, __) => ListTile(
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(_hhmm(a.scheduledTime), style: const TextStyle(color: AppColors.textSecondary)),
              ),
              body: _panelBody(a, n),
            )).toList(),
          ),
        );
      }),
    );
  }

  Widget _panelBody(ExerciseActivity a, HabitNotifier n) {
    final t = AppLocalizations.of(context);
    final finished = a.remainingDuration.inSeconds == 0;

    String _fmt(Duration d) {
      String dd(int x) => x.toString().padLeft(2, '0');
      return '${dd(d.inHours)}:${dd(d.inMinutes.remainder(60))}:${dd(d.inSeconds.remainder(60))}';
    }

    void toggle() {
      if (a.isRunning) {
        n.stopExerciseTimer(a.id);
      } else {
        n.startExerciseTimer(a);
      }
    }

    void reset() {
      n.resetExerciseTimer(a.id);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: [
        Text(
          _fmt(a.remainingDuration),
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: finished ? Colors.green : AppColors.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textSecondary),
            onPressed: () => _addOrEdit(existing: a),
          ),
          const Spacer(),
          FilledButton(
            onPressed: finished ? reset : toggle,
            child: Text(finished ? t.reset : (a.isRunning ? t.stop : t.start)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => n.deleteExerciseActivity(a.id), // Notifier จะหยุด timer ให้เอง
          ),
        ])
      ]),
    );
  }

  // ===== Dialog เพิ่ม/แก้ไข (เลือกเวลา & duration) =====
  Future<void> _addOrEdit({ExerciseActivity? existing}) async {
    final t = AppLocalizations.of(context);
    final name = TextEditingController(text: existing?.name);
    TimeOfDay startTime = existing?.scheduledTime ?? TimeOfDay.now();
    Duration selectedDuration = existing?.goalDuration ?? const Duration(minutes: 10);

    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          Future<void> _pickDurationBottomSheet() async {
            Duration temp = selectedDuration;
            final picked = await showModalBottomSheet<Duration>(
              context: ctx,
              builder: (bctx) {
                return SafeArea(
                  child: SizedBox(
                    height: 260,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(t.selectDuration, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.hm,
                            initialTimerDuration: temp,
                            minuteInterval: 1,
                            onTimerDurationChanged: (d) => temp = d,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              TextButton(onPressed: () => Navigator.of(bctx).pop(), child: Text(t.cancel)),
                              const Spacer(),
                              FilledButton(onPressed: () => Navigator.of(bctx).pop(temp), child: Text(t.use)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            if (picked != null) setS(() => selectedDuration = picked);
          }

          Future<void> _pickStartTime() async {
            final picked = await showTimePicker(
              context: ctx,
              initialTime: startTime,
              initialEntryMode: TimePickerEntryMode.input,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );
            if (picked != null) setS(() => startTime = picked);
          }

          String fmtDur(Duration d) {
            final h = d.inHours, m = d.inMinutes.remainder(60);
            return '${h}h ${m}m';
          }

          return AlertDialog(
            title: Text(existing == null ? t.addActivity : t.editActivity),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: InputDecoration(labelText: t.activityName), autofocus: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text(t.duration)),
                      Text(fmtDur(selectedDuration), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDurationBottomSheet,
                        icon: const Icon(Icons.timer_outlined),
                        label: Text(t.pick),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text(t.startTime)),
                      Text(_hhmm(startTime), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => setS(() => startTime = TimeOfDay.now()), child: Text(t.now)),
                      const SizedBox(width: 4),
                      OutlinedButton.icon(
                        onPressed: _pickStartTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(t.pick),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
              FilledButton(
                onPressed: (name.text.trim().isEmpty || selectedDuration.inMinutes == 0)
                    ? null
                    : () => Navigator.pop(ctx, {
                          'name': name.text.trim(),
                          'time': startTime,
                          'duration': selectedDuration,
                        }),
                child: Text(t.save),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted) return;

    if (res != null && (res['name'] as String).isNotEmpty) {
      final n = context.read<HabitNotifier>();
      if (existing != null) {
        n.stopExerciseTimer(existing.id); // หยุดตัวเดิมก่อนอัปเดต
      }
      final a = ExerciseActivity(
        id: existing?.id ?? '',
        name: res['name'] as String,
        scheduledTime: res['time'] as TimeOfDay,
        goalDuration: res['duration'] as Duration,
      );
      await n.saveExerciseActivity(a);
      // ไม่ต้อง setState(); Consumer จะอัปเดตให้เอง
    }
  }
}

String _hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
