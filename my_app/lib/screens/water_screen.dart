import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';

const Color primaryColor = Color(0xFF0ABAB5);
const Color textColor = Color(0xFF000000);
const Color secondaryTextColor = Colors.grey;

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});
  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitNotifier>().fetchDailyWaterIntake();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake'), foregroundColor: primaryColor),
      body: Consumer<HabitNotifier>(builder: (context, n, _) {
        final count = n.dailyWaterCount;
        final goal = n.dailyWaterGoal;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Today: $count of $goal glasses',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
              children: List.generate(goal, (i) => Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: i < count ? primaryColor : Colors.grey.shade300,
                  shape: BoxShape.circle),
              )),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.read<HabitNotifier>().incrementWaterIntake(1),
              child: const Text('+ Add'),
            ),
          ]),
        );
      }),
    );
  }
}
