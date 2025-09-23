import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/water_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/date_provider.dart';
import '../providers/bmi_provider.dart';
import '../providers/mood_provider.dart';  
import '../providers/meal_provider.dart';
import 'meal_logging_screen.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';


class DashboardPage extends StatelessWidget {
  final void Function(int)? onTabChange;
  
  const DashboardPage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final water = context.watch<WaterProvider>().water;
    final exercise = context.watch<ExerciseProvider>().exercise;
    final date = context.watch<DateProvider>().date;

    // โหลดข้อมูล meal count เมื่อเริ่มต้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadTodayMealCount();
    });

    final formattedDate = date.toLocal().toString().split(' ')[0];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.goodMorning,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        t.date(formattedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                    child: const CircleAvatar(child: Icon(Icons.person)),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // TableCalendar
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: date,
                      selectedDayPredicate: (day) => isSameDay(day, date),
                      onDaySelected: (selectedDay, focusedDay) {
                        context.read<DateProvider>().setDate(selectedDay);
                      },
                      calendarFormat: CalendarFormat.week,
                      headerStyle: HeaderStyle(
                        titleCentered: true, // ทำให้ข้อความเดือนปีอยู่ตรงกลาง
                        formatButtonVisible:
                            false, // ซ่อนปุ่มเปลี่ยนรูปแบบปฏิทิน
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade800),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14), // ✅ มนเฉพาะมุมบนซ้าย
                            topRight: Radius.circular(14), // ✅ มนเฉพาะมุมบนขวา
                          ),
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: true,
                        outsideTextStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.black, // ✅ พื้นหลังวันที่ถูกเลือก
                          shape: BoxShape.rectangle, // หรือ BoxShape.rectangle
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.white, // ✅ สีข้อความของวันที่ถูกเลือก
                          fontWeight: FontWeight.bold,
                        ),
                        todayDecoration: BoxDecoration(
                          color:
                              Colors.grey, // ✅ พื้นหลังของวันนี้ (ไม่ได้เลือก)
                        ),
                        todayTextStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // น้ำหนักวันนี้
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
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

              // อารมณ์วันนี้
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
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

              // การดำเนินการวันนี้
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    _ProgressItem(
                      icon: "💧",
                      label: t.waterIntakeLabel,  
                      progressText: "${(water / 2000 * 100).toInt()}%",
                      progress: water / 2000,
                      onTap: () {
                        if (onTabChange != null) {
                          onTabChange!(2); // Water tab index = 2
                        } else {
                          Navigator.of(context).pushNamed('/water');
                        }
                      },
                    ),
                    _ProgressItem(
                      icon: "🏃‍♂️",
                      label: t.exerciseLabel,
                      progressText: exercise >= 30 ? t.done : "${exercise} min",
                      progress: (exercise / 30).clamp(0.0, 1.0),
                      onTap: () {
                        if (onTabChange != null) {
                          onTabChange!(3); // Exercise tab index = 3
                        } else {
                          Navigator.of(context).pushNamed('/exercise');
                        }
                      },
                    ),
                    _ProgressItem(
                      icon: "😴",
                      label: t.sleepLoggedLabel,
                      progressText: "8h 30m",
                      progress: 0.85,
                      onTap: () {
                        if (onTabChange != null) {
                          onTabChange!(4); // Sleep tab index = 4
                        } else {
                          Navigator.of(context).pushNamed('/sleep');
                        }
                      },
                    ),
                    Consumer<MealProvider>(
                      builder: (context, mealProvider, child) {
                        return _ProgressItem(
                          icon: "🍽️",
                          label: t.mealsLoggedLabel,
                          progressText: mealProvider.mealProgressText,
                          progress: mealProvider.mealProgress,
                          onTap: () {
                            if (onTabChange != null) {
                              onTabChange!(1); // Meal tab index = 1
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MealLoggingScreen(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
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

class _ProgressItem extends StatelessWidget {
  final String icon;
  final String label;
  final String progressText;
  final double progress;
  final VoidCallback onTap;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.progressText,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(progressText),
          IconButton(onPressed: onTap, icon: const Icon(Icons.arrow_forward_ios)),
        ],
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
                      labelText: t.weightKg,
                      border: const OutlineInputBorder(),
                      isDense: true,
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
                      labelText: t.heightCm,
                      border: const OutlineInputBorder(),
                      isDense: true,
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
