import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'providers/water_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/date_provider.dart';
import 'providers/bmi_provider.dart';
import 'providers/mood_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>().water;
    final exercise = context.watch<ExerciseProvider>().exercise;
    final meal = context.watch<MealProvider>().meal;
    final date = context.watch<DateProvider>().date;

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
                      const Text(
                        'สวัสดีตอนเช้า, Alex!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'วันที่ $formattedDate',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const CircleAvatar(child: Icon(Icons.person)),
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
                    const Text(
                      "น้ำหนักวันนี้",
                      style: TextStyle(
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
                  children: const [
                    Text(
                      "อารมณ์วันนี้",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _EmojiMood("😐", "Poor"),
                        _EmojiMood("🙂", "Fair"),
                        _EmojiMood("😊", "Good"),
                        _EmojiMood("😁", "Great"),
                        _EmojiMood("🥳", "Excellent"),
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
                    const Text(
                      "การดำเนินการวันนี้",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),
                    _ProgressItem(
                      icon: "💧",
                      label: "Water Intake",
                      progressText: "${(water / 2000 * 100).toInt()}%",
                      progress: water / 2000,
                      onTap: () =>
                          context.read<WaterProvider>().setWater(water + 250),
                    ),
                    _ProgressItem(
                      icon: "🏃‍♂️",
                      label: "Exercise",
                      progressText: exercise >= 30 ? "Done" : "${exercise} min",
                      progress: (exercise / 30).clamp(0.0, 1.0),
                      onTap: () => context.read<ExerciseProvider>().setExercise(
                        exercise + 10,
                      ),
                    ),
                    _ProgressItem(
                      icon: "🍽️",
                      label: "Meals Logged",
                      progressText: meal.isNotEmpty ? "2/3" : "0/3",
                      progress: meal.isNotEmpty ? 0.66 : 0.0,
                      onTap: () =>
                          context.read<MealProvider>().setMeal("อาหารกลางวัน"),
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
  const _EmojiMood(this.emoji, this.label, {super.key});

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
              color: isSelected ? const Color.fromARGB(139, 10, 186, 180) : Colors.transparent,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: isSelected ? const Color(0xFF0ABAB5) : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF0ABAB5) : Colors.black,
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
          IconButton(onPressed: onTap, icon: const Icon(Icons.add_circle)),
        ],
      ),
    );
  }
}

class _BMISection extends StatelessWidget {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  _BMISection({super.key});

  void _submit(BuildContext context) {
    final double? weight = double.tryParse(weightController.text);
    final double? height = double.tryParse(heightController.text);

    if (weight != null && height != null && height > 0) {
      context.read<BmiProvider>().setValues(weight, height);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: const InputDecoration(
                      labelText: 'น้ำหนัก (kg)',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'ส่วนสูง (cm)',
                      border: OutlineInputBorder(),
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
                          backgroundColor: const Color(0xFF919191),
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
                        child: const Text("แก้ไข"),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0ABAB5),
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
                      child: const Text("บันทึก"),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
