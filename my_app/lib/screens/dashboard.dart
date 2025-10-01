import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// removed TableCalendar; custom week picker implemented below

import '../providers/habit_notifier.dart';
import '../providers/date_provider.dart';
import '../providers/bmi_provider.dart';
import '../providers/mood_provider.dart';  
import '../providers/meal_provider.dart';
// ...existing imports
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';


class DashboardPage extends StatelessWidget {
  final void Function(int)? onTabChange;
  
  const DashboardPage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
  final habit = context.watch<HabitNotifier>();
  final water = habit.dailyWaterMl; // ml
  // exercise value not used in this layout; keep provider available if needed later
    final date = context.watch<DateProvider>().date;

    // โหลดข้อมูล meal count เมื่อเริ่มต้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadTodayMealCount();
    });

    final formattedDate = date.toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: DashboardTopAppBar(
        greeting: t.goodMorning,
        date: t.date(formattedDate),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal week date cards (custom)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: _WeekDatePicker(selectedDate: date),
              ),

              const SizedBox(height: 15),

              // น้ำหนักวันนี้ (card)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Colors.black12,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.todayWeight,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BMISection(),
                    ],
                  ),
                ),
              ),

              // อารมณ์วันนี้ (card)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Colors.black12,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.todayMood,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _EmojiMood("😐", t.healthPoor),
                          _EmojiMood("🙂", t.healthFair),
                          _EmojiMood("😊", t.healthGood),
                          _EmojiMood("😁", t.healthGreat),
                          _EmojiMood("🥳", t.healthExcellent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Progress header and custom layout (no outer Card)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.todayProgress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Main layout: left = tall water card, right = stacked sleep & calories
                    Builder(builder: (context) {
                      final screenH = MediaQuery.of(context).size.height;
                      // Tweak card height slightly downward to better match the reference guideline.
                      final double cardHeight = (screenH * 0.44).clamp(290.0, 500.0);
                      // Keep the inner water bar proportional to the card but with some padding.
                      final double innerBarHeight = (cardHeight - 90).clamp(130.0, 460.0);
                      // split right column into two equal-height children (minus spacing)
                      final double childHeight = (cardHeight - 8) / 2;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Water (left) — make it half the row
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              // make the water card the same height as the right column so tops align
                              height: cardHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
                                ),
                                  child: _WaterProgressCard(
                                  waterMl: water,
                                  goalMl: 2000,
                                  timeline: habit.buildWaterTimeline(water),
                                  // use the full innerBarHeight so the inner bar scales with the card
                                  barHeight: innerBarHeight,
                                  onTap: () {
                                    if (onTabChange != null) {
                                      onTabChange!(2);
                                    } else {
                                      Navigator.of(context).pushNamed('/water');
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right column: Sleep (top) and Calories (bottom) stacked to match left height
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: cardHeight,
                              child: Column(
                                children: [
                                  // Sleep card: fixed to half the available cardHeight so it
                                  // matches the Calories card height
                                  SizedBox(
                                    height: childHeight,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
                                      ),
                                      child: _SleepCard(
                                        hoursText: '8h 30m',
                                        quality: habit.latestSleepLog?['starCount'] as int?,
                                        onTap: () {
                                          if (onTabChange != null) {
                                            onTabChange!(4);
                                          } else {
                                            Navigator.of(context).pushNamed('/sleep');
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Calories card: match the same height as sleep card
                                  SizedBox(
                                    height: childHeight,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
                                      ),
                                      child: _CaloriesCard(
                                        kcal: 760,
                                        goalKcal: 2000,
                                        onTap: () {
                                          if (onTabChange != null) {
                                            onTabChange!(1);
                                          } else {
                                            Navigator.of(context).pushNamed('/meal');
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom horizontal week date picker (shows 7 days centered on selected date)
class _WeekDatePicker extends StatelessWidget {
  final DateTime selectedDate;

  const _WeekDatePicker({required this.selectedDate});

  List<DateTime> _buildWeek(DateTime center) {
    // build 7-day window where center is the middle (index 3)
    final start = DateTime(center.year, center.month, center.day).subtract(const Duration(days: 3));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildWeek(selectedDate);
    final today = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((d) {
          final isSelected = d.year == selectedDate.year && d.month == selectedDate.month && d.day == selectedDate.day;
          final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: GestureDetector(
              onTap: () => context.read<DateProvider>().setDate(d),
              child: _DateCard(date: d, selected: isSelected, isToday: isToday),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool isToday;

  const _DateCard({required this.date, required this.selected, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final cardBg = selected
        ? null
        : Colors.white;

    // Get localized day name
    final t = AppLocalizations.of(context);
    final dayNames = [t.dayNameSun, t.dayNameMon, t.dayNameTue, t.dayNameWed, t.dayNameThu, t.dayNameFri, t.dayNameSat];
    final dayName = dayNames[date.weekday % 7];

    return Container(
      width: 72,
      height: 90,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary.withOpacity(0.9), primary.withOpacity(0.6)],
              )
            : null,
        border: Border.all(color: selected ? primary : Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date.day.toString().padLeft(2, '0'),
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Today marker
          if (isToday)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected ? Colors.white : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

// องค์ประกอบย่อย
class _EmojiMood extends StatelessWidget {
  final String emoji;
  final String label;
  const _EmojiMood(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<MoodProvider>().selectedMood;
    final isSelected = selected == label;

    return GestureDetector(
      onTap: () => context.read<MoodProvider>().setMood(label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isSelected
                  ? const Color.fromARGB(139, 10, 186, 180)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ... removed old _ProgressItem; new visual cards added below

class _WaterProgressCard extends StatelessWidget {
  final int waterMl;
  final int? goalMl;
  final List<Map<String, String>>? timeline;
  final double? barHeight;
  final VoidCallback onTap;

  const _WaterProgressCard({required this.waterMl, this.goalMl, this.timeline, this.barHeight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
  final target = (goalMl ?? 2000);
  final pct = (waterMl / target).clamp(0, 1).toDouble();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.waterIntakeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                // show goal as 2 Liters per request
                Text('2 Liters', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Vertical bar + timeline
                Column(
                  children: [
            Container(
              width: 28,
              height: barHeight ?? 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade100,
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: (barHeight ?? 140) * pct,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.gradientLightEnd, AppColors.primary],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // timeline / text — make the timeline area match the bar height and space items evenly
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${(waterMl / 1000).toStringAsFixed(1)} Liters', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: barHeight ?? 140,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // render reversed so the first (earliest) time is placed at the bottom
                            for (final item in (timeline ?? const []).reversed)
                              _WaterTimelineItem(time: item['time'] ?? '', amount: item['amount'] ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterTimelineItem extends StatelessWidget {
  final String time;
  final String amount;

  const _WaterTimelineItem({required this.time, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.chartPrimary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  final String hoursText;
  final int? quality;
  final VoidCallback onTap;

  const _SleepCard({required this.hoursText, this.quality, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.sleep, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // placeholder for stylized sleep graphic (use asset if available)
            SizedBox(
              height: 48,
              child: Center(
                child: Image.asset(
                  'images/sleep-dashboard.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.bedtime, size: 40, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // center the hours text while keeping the "Sleep" label at top-left
            Center(child: Text(hoursText, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (quality != null) ...[
              const SizedBox(height: 6),
              Center(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(quality!.clamp(0,5), (i) => Icon(Icons.star, size: 14, color: AppColors.primary))
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  final int kcal;
  final int goalKcal;
  final VoidCallback onTap;

  const _CaloriesCard({required this.kcal, required this.goalKcal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (kcal / goalKcal).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calories', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // show a centered plate/cup icon and the kcal number beneath it
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu, size: 48, color: AppColors.chartPrimary),
                  const SizedBox(height: 8),
                  Text('$kcal KCal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // remaining kcal text and progress bar directly under the main metric
            Center(child: Text('${goalKcal - kcal} kCal left', style: const TextStyle(color: Colors.grey))),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: pct, color: AppColors.chartPrimary, backgroundColor: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

}

class _BMISection extends StatelessWidget {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  _BMISection();

  void _submit(BuildContext context) {
    final double? weight = double.tryParse(weightController.text);
    final double? height = double.tryParse(heightController.text);

    if (weight != null && height != null && height > 0) {
      context.read<BmiProvider>().setValues(weight, height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Consumer<BmiProvider>(
      builder: (context, bmiProvider, _) {
        final isReadOnly = bmiProvider.submitted;

        // เซ็ตค่าใน input ถ้ากดบันทึกแล้ว (กันไว้ให้โชว์ค่าที่เคยกรอก)
        if (isReadOnly) {
          weightController.text = bmiProvider.weight?.toString() ?? '';
          heightController.text = bmiProvider.height?.toString() ?? '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ➤ บรรทัด input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    readOnly: isReadOnly,
                    decoration: InputDecoration(
                      hintText: t.weightKg,
                      // minimal rounded style
                      filled: true,
                      fillColor: AppColors.lightGray,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Color(0xFF9E9E9E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    readOnly: isReadOnly,
                    decoration: InputDecoration(
                      hintText: t.heightCm,
                      // minimal rounded style
                      filled: true,
                      fillColor: AppColors.lightGray,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      prefixIcon: const Icon(Icons.height, color: Color(0xFF9E9E9E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ➤ บรรทัดปุ่ม/ผลลัพธ์
            isReadOnly
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BMI: ${bmiProvider.bmi?.toStringAsFixed(2) ?? '-'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () => bmiProvider.reset(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greyBackground,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, // ✅ ทำให้ตัวหนา
                            fontSize: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(t.edit),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, // ✅ ทำให้ตัวหนา
                          fontSize: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(t.save),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
