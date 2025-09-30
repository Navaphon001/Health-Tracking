import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ใช้ CupertinoTimerPicker ใน dialog
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';
import '../providers/exercise_provider.dart';
import '../providers/physical_info_provider.dart';
import '../models/exercise_activity.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  String _fmtDur(Duration d) {
    final h = d.inHours, m = d.inMinutes.remainder(60), s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // ensure habit activities are loaded (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = context.read<HabitNotifier>();
      if (n.exerciseActivities.isEmpty) n.fetchExerciseActivities();
      // load user weight into ExerciseProvider
      final weight = context.read<PhysicalInfoProvider?>()?.weight;
      if (weight != null) context.read<ExerciseProvider>().setUserWeight(weight);
    });

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.exercise,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (Date row and calendar intentionally removed per design request)

            // Single selection bar that opens a modal to choose activity type (taller, raised, minimal)
            Consumer<ExerciseProvider>(builder: (context, p, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Material(
                  elevation: 6,
                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showActivityPicker(context, p.selected),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 64),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary, size: 22),
                          const SizedBox(width: 14),
                          Expanded(child: Text('Select activity type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Activity chips removed - selected activity will display inside the timer card

            // Timer / controls and calories - redesigned
            Consumer<ExerciseProvider>(builder: (context, p, _) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected activity pill
                      Consumer<ExerciseProvider>(builder: (context, p2, _) {
                        final at = p2.selected;
                        final icon = at == ActivityType.walk
                            ? Icons.directions_walk
                            : at == ActivityType.run
                                ? Icons.directions_run
                                : at == ActivityType.bike
                                    ? Icons.directions_bike
                                    : at == ActivityType.swim
                                        ? Icons.pool
                                        : Icons.sports_soccer;
                        final label = _activityLabel(at);
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showActivityPicker(context, at),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(_fmtDur(p.elapsed),
                            style: TextStyle(fontSize: 36, fontFamily: 'monospace', color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: p.isRunning ? p.stop : p.start,
                              icon: Icon(p.isRunning ? Icons.pause : Icons.play_arrow),
                              label: Text(p.isRunning ? t.stop : t.start),
                              style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: p.reset,
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.primary), shape: const StadiumBorder()),
                            child: Text(t.reset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Prominent calories summary (full width)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 84),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: SizedBox(
                          height: 84,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${p.calories.toStringAsFixed(1)}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                // Calories label only (steps removed)
                                Text(t.calories, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // small stats row removed; steps now displayed inside the calories box

            const SizedBox(height: 12),

            // Existing activities (from HabitNotifier) shown as list
            Expanded(
              child: Consumer<HabitNotifier>(builder: (context, n, _) {
                final list = n.exerciseActivities;
                if (list.isEmpty) {
                  // placeholder removed per design: show nothing when there are no activities
                  return const SizedBox.shrink();
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final a = list[idx];
                    return ListTile(
                      title: Text(a.name),
                      subtitle: Text('${_hhmm(a.scheduledTime)} • ${a.goalDuration.inMinutes} ${t.minutes}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: Icon(Icons.edit, color: Theme.of(context).textTheme.bodySmall?.color), onPressed: () => _showAddEditDialog(context, existing: a)),
                          const SizedBox(width: 8),
                          FilledButton(onPressed: () => n.deleteExerciseActivity(a.id), child: Text(t.delete)),
                        ]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

    static String _activityLabel(ActivityType t) {
      switch (t) {
        case ActivityType.walk:
          return 'Walking';
        case ActivityType.run:
          return 'Running';
        case ActivityType.bike:
          return 'Cycling';
        case ActivityType.swim:
          return 'Swimming';
        case ActivityType.sport:
          return 'Sport';
      }
    }

  Future<void> _showActivityPicker(BuildContext context, ActivityType current) async {
  final provider = context.read<ExerciseProvider>();
    final result = await showModalBottomSheet<ActivityType>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ActivityType.values.map((at) {
              final label = _activityLabel(at);
              final icon = at == ActivityType.walk
                  ? Icons.directions_walk
                  : at == ActivityType.run
                      ? Icons.directions_run
                      : at == ActivityType.bike
                          ? Icons.directions_bike
                          : at == ActivityType.swim
                              ? Icons.pool
                              : Icons.sports_soccer;
              return ListTile(
                leading: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
                title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () => Navigator.of(ctx).pop(at),
              );
            }).toList(),
          ),
        );
      },
    );

    if (result != null) {
      provider.select(result);
    }
  }

    // Small bar chart widget implemented inline to avoid adding dependencies
  }

  Future<void> _showAddEditDialog(BuildContext context, {ExerciseActivity? existing}) async {
    final t = AppLocalizations.of(context);

    // If creating a new activity (from FAB), show a minimal dialog with only the name.
    if (existing == null) {
      final name = TextEditingController();
      final res = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(t.addActivity),
            content: TextField(controller: name, decoration: InputDecoration(labelText: t.activityName), autofocus: true),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
              FilledButton(
                onPressed: name.text.trim().isEmpty ? null : () => Navigator.pop(ctx, name.text.trim()),
                child: Text(t.save),
              ),
            ],
          );
        },
      );

      if (res != null && res.isNotEmpty) {
        final n = context.read<HabitNotifier>();
        final a = ExerciseActivity(
          id: '',
          name: res,
          scheduledTime: TimeOfDay.now(),
          goalDuration: const Duration(minutes: 10),
        );
        await n.saveExerciseActivity(a);
      }
      return;
    }

    // Otherwise editing an existing activity: keep full dialog (duration + start time)
    final name = TextEditingController(text: existing.name);
    TimeOfDay startTime = existing.scheduledTime;
    Duration selectedDuration = existing.goalDuration;

    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
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
          title: Text(t.editActivity),
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
      }),
    );

    if (res != null && (res['name'] as String).isNotEmpty) {
      final n = context.read<HabitNotifier>();
      // keep existing stopExerciseTimer call for legacy behavior
      n.stopExerciseTimer(existing.id);
      final a = ExerciseActivity(
        id: existing.id,
        name: res['name'] as String,
        scheduledTime: res['time'] as TimeOfDay,
        goalDuration: res['duration'] as Duration,
      );
      await n.saveExerciseActivity(a);
    }
  }

  // Removed _MiniBarChart - chart and no-data box replaced by prominent calories display

String _hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
