import 'dart:async';
import 'package:flutter/material.dart';
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
  String? _openId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitNotifier>().fetchExerciseActivities();
    });
  }

  @override
  void dispose() {
    for (final a in context.read<HabitNotifier>().exerciseActivities) {
      a.timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise'), foregroundColor: primaryColor),
      floatingActionButton: FloatingActionButton(onPressed: _addOrEdit, child: const Icon(Icons.add)),
      body: Consumer<HabitNotifier>(builder: (context, n, _) {
        final list = n.exerciseActivities;
        if (list.isEmpty) return const Center(child: Text('No activities added yet.', style: TextStyle(color: secondaryTextColor)));
        return SingleChildScrollView(
          child: ExpansionPanelList.radio(
            initialOpenPanelValue: _openId,
            children: list.map((a) => ExpansionPanelRadio(
              value: a.id,
              headerBuilder: (_, __) => ListTile(
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    void toggle() {
      if (a.isRunning) {
        a.timer?.cancel();
      } else if (a.remainingDuration.inSeconds > 0) {
        a.timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) return t.cancel();
          if (a.remainingDuration.inSeconds <= 0) {
            t.cancel();
            setState(() => a.isRunning = false);
          } else {
            setState(() => a.remainingDuration -= const Duration(seconds: 1));
          }
        });
      }
      setState(() => a.isRunning = !a.isRunning);
    }

    void reset() {
      a.timer?.cancel();
      setState(() {
        a.isRunning = false;
        a.remainingDuration = a.goalDuration;
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: [
        Text(_fmt(a.remainingDuration),
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: finished ? Colors.green : textColor, fontFamily: 'monospace')),
        const SizedBox(height: 12),
        Row(children: [
          IconButton(icon: const Icon(Icons.edit, color: secondaryTextColor), onPressed: () => _addOrEdit(existing: a)),
          const Spacer(),
          FilledButton(onPressed: finished ? reset : toggle, child: Text(finished ? 'Reset' : (a.isRunning ? 'Stop' : 'Start'))),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => n.deleteExerciseActivity(a.id)),
        ])
      ]),
    );
  }

  Future<void> _addOrEdit({ExerciseActivity? existing}) async {
    final name = TextEditingController(text: existing?.name);
    TimeOfDay time = existing?.scheduledTime ?? TimeOfDay.now();
    int h = existing?.goalDuration.inHours ?? 0;
    int m = existing?.goalDuration.inMinutes.remainder(60) ?? 10;

    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Activity' : 'Edit Activity'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Activity Name')),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Duration'),
              subtitle: Text('${h}h ${m}m'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: () => setS(() => h = (h + 23) % 24), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => setS(() => h = (h + 1) % 24), icon: const Icon(Icons.add_circle_outline)),
                const SizedBox(width: 8),
                IconButton(onPressed: () => setS(() => m = (m + 59) % 60), icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: () => setS(() => m = (m + 1) % 60), icon: const Icon(Icons.add_circle_outline)),
              ]),
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_hhmm(time)),
              onTap: () async {
                final p = await showTimePicker(context: context, initialTime: time);
                if (p != null) setS(() => time = p);
              },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, {'name': name.text, 'time': time, 'hours': h, 'minutes': m}), child: const Text('Save')),
          ],
        );
      }),
    );

    if (res != null && (res['name'] as String).isNotEmpty) {
      final n = context.read<HabitNotifier>();
      final a = ExerciseActivity(
        id: existing?.id ?? '',
        name: res['name'] as String,
        scheduledTime: res['time'] as TimeOfDay,
        goalDuration: Duration(hours: res['hours'] as int, minutes: res['minutes'] as int),
      );
      await n.saveExerciseActivity(a);
      setState(() {});
    }
  }
}

String _hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
