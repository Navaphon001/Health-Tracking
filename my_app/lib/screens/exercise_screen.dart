import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';
import '../models/exercise_activity.dart';

const Color primaryColor = Color(0xFF0ABAB5);
const Color textColor = Color(0xFF000000);
const Color secondaryTextColor = Colors.grey;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise'), foregroundColor: primaryColor),
      floatingActionButton: FloatingActionButton(onPressed: _addOrEdit, child: const Icon(Icons.add)),
      body: Consumer<HabitNotifier>(builder: (context, n, _) {
        final list = n.exerciseActivities;
        if (list.isEmpty) {
          return const Center(
            child: Text('No activities added yet.', style: TextStyle(color: secondaryTextColor)),
          );
        }
        return SingleChildScrollView(
          child: ExpansionPanelList.radio(
            children: list.map((a) => ExpansionPanelRadio(
              value: a.id,
              headerBuilder: (_, __) => ListTile(
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${_labelOf(a.activityType)} • ${a.caloriesBurned?.toStringAsFixed(0) ?? '-'} kcal',
                  style: const TextStyle(color: secondaryTextColor),
                ),
                trailing: Text(_hhmm(a.scheduledTime), style: const TextStyle(color: secondaryTextColor)),
              ),
              body: _panelBody(a, n),
            )).toList(),
          ),
        );
      }),
    );
  }

  Widget _panelBody(ExerciseActivity a, HabitNotifier n) {
    final finished = a.remainingDuration.inSeconds == 0;

    String _fmt(Duration d) {
      String dd(int x) => x.toString().padLeft(2, '0');
      return '${dd(d.inHours)}:${dd(d.inMinutes.remainder(60))}:${dd(d.inSeconds.remainder(60))}';
    }

    void toggle() => a.isRunning ? n.stopExerciseTimer(a.id) : n.startExerciseTimer(a);
    void reset() => n.resetExerciseTimer(a.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: [
        Text(
          _fmt(a.remainingDuration),
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: finished ? Colors.green : textColor,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Chip(label: Text(_labelOf(a.activityType))),
            const SizedBox(width: 8),
            if (a.caloriesBurned != null)
              Chip(label: Text('${a.caloriesBurned!.toStringAsFixed(0)} kcal')),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.edit, color: secondaryTextColor),
            onPressed: () => _addOrEdit(existing: a),
          ),
          const Spacer(),
          FilledButton(
            onPressed: finished ? reset : toggle,
            child: Text(finished ? 'Reset' : (a.isRunning ? 'Stop' : 'Start')),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => n.deleteExerciseActivity(a.id),
          ),
        ])
      ]),
    );
  }

  // ===== Dialog เพิ่ม/แก้ไข (เลือกประเภท + ระยะเวลา + เวลาเริ่ม) =====
  Future<void> _addOrEdit({ExerciseActivity? existing}) async {
    final n = context.read<HabitNotifier>();
    final double userWeightKg = _resolveUserWeightKg(n); // ใช้คำนวณครั้งเดียว

    final name = TextEditingController(text: existing?.name);
    TimeOfDay startTime = existing?.scheduledTime ?? TimeOfDay.now();
    Duration selectedDuration = existing?.goalDuration ?? const Duration(minutes: 10);
    ActivityType selectedType = existing?.activityType ?? ActivityType.walk;

    double estKcal = _calcKcal(selectedType, userWeightKg, selectedDuration);

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
                        const Text('Select Duration', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              TextButton(onPressed: () => Navigator.of(bctx).pop(), child: const Text('Cancel')),
                              const Spacer(),
                              FilledButton(onPressed: () => Navigator.of(bctx).pop(temp), child: const Text('Use')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            if (picked != null) {
              setS(() {
                selectedDuration = picked;
                estKcal = _calcKcal(selectedType, userWeightKg, selectedDuration);
              });
            }
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
            title: Text(existing == null ? 'Add Activity' : 'Edit Activity'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Activity Name'), autofocus: true),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<ActivityType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'ประเภทกิจกรรม'),
                    items: ActivityType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(_labelOf(t)));
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setS(() {
                        selectedType = v;
                        estKcal = _calcKcal(selectedType, userWeightKg, selectedDuration);
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: Text('Duration')),
                      Text(fmtDur(selectedDuration), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDurationBottomSheet,
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text('Pick'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: Text('Start Time')),
                      Text(_hhmm(startTime), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => setS(() => startTime = TimeOfDay.now()), child: const Text('Now')),
                      const SizedBox(width: 4),
                      OutlinedButton.icon(
                        onPressed: _pickStartTime,
                        icon: const Icon(Icons.schedule),
                        label: const Text('Pick'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // แสดงผลแคลอรี่ (ที่เราจะ "บันทึก" จริงๆ)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFCFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ประมาณการเผาผลาญแคลอรี่'),
                        const SizedBox(height: 6),
                        Text(
                          '${estKcal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'คำนวณตอนบันทึกเท่านั้น (น้ำหนักเปลี่ยนภายหลังจะไม่กระทบ)',
                          style: const TextStyle(color: secondaryTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: (name.text.trim().isEmpty || selectedDuration.inMinutes == 0)
                    ? null
                    : () => Navigator.pop(ctx, {
                          'name': name.text.trim(),
                          'time': startTime,
                          'duration': selectedDuration,
                          'type': selectedType,
                          'calories': estKcal, // <<< บันทึกเฉพาะ kcal
                        }),
                child: const Text('Save'),
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
        n.stopExerciseTimer(existing.id);
      }
      final a = ExerciseActivity(
        id: existing?.id ?? '',
        name: res['name'] as String,
        scheduledTime: res['time'] as TimeOfDay,
        goalDuration: res['duration'] as Duration,
        activityType: res['type'] as ActivityType,
        caloriesBurned: (res['calories'] as num?)?.toDouble(), // <<< บันทึกเฉพาะ kcal
      );
      await n.saveExerciseActivity(a);
    }
  }
}

// ===== Helpers =====
String _hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _labelOf(ActivityType t) {
  switch (t) {
    case ActivityType.walk: return 'เดิน';
    case ActivityType.run:  return 'วิ่ง';
    case ActivityType.bike: return 'ปั่นจักรยาน';
    case ActivityType.swim: return 'ว่ายน้ำ';
    case ActivityType.sport:return 'กีฬา';
  }
}

double _metOf(ActivityType t) => ExerciseActivity.metOf(t);

double _calcKcal(ActivityType type, double weightKg, Duration duration) {
  final met = _metOf(type);
  final minutes = duration.inMinutes;
  return met * 3.5 * weightKg / 200.0 * minutes;
}

/// ดึงน้ำหนักจาก Notifier/โปรไฟล์ (หรือ fallback = 60)
double _resolveUserWeightKg(HabitNotifier n) {
  try {
    final dyn = n as dynamic;
    final v = dyn.userWeightKg;
    if (v is num) return v.toDouble();
  } catch (_) {}
  return 60.0;
}
