import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/habit_notifier.dart';

const Color primaryColor = Color(0xFF0ABAB5);

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});
  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  // เลือก drink + ml (ช่องเดียว)
  int? _selectedDrinkIndex;
  final _mlCtl = TextEditingController();
  final List<int> _mlOptions = const [120, 150, 180, 200, 220, 250, 300, 350, 500];

  @override
  void initState() {
    super.initState();
    _mlCtl.text = HabitNotifier.baseGlassMl.toString(); // ค่าเริ่มต้น 250
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitNotifier>().fetchDailyWaterIntake();
    });
  }

  @override
  void dispose() {
    _mlCtl.dispose();
    super.dispose();
  }

  int? _finalMl() => int.tryParse(_mlCtl.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('การดื่มน้ำ', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('บันทึกการดื่มน้ำประจำวัน', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Consumer<HabitNotifier>(
        builder: (context, n, _) {
          final totalMl = n.dailyWaterMl;
          final targetMl = n.dailyWaterTargetMl;
          final percent = (targetMl == 0) ? 0.0 : (totalMl / targetMl).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // วงกลมความคืบหน้า
                Center(
                  child: SizedBox(
                    width: 160, height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160, height: 160,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(primaryColor),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$totalMl/$targetMl',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                            const Text('ml', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // คอมโบฟิลด์: กรอกเอง + เลือกจากรายการ (ช่องเดียว)
                Center(
                  child: SizedBox(
                    width: 260,
                    child: _MlComboField(
                      controller: _mlCtl,
                      options: _mlOptions,
                      label: 'ปริมาณ (ml)',
                      onChanged: (_) => setState(() {}), // อัปเดต hint บนการ์ด
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // สรุปจำนวนแก้ว
                Text(
                  'วันนี้: ${n.dailyWaterCount} แก้ว',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                // การ์ดเลือกเครื่องดื่ม + ปุ่มเพิ่มชื่อเครื่องดื่ม
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('เลือกเครื่องดื่ม', style: TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            IconButton(
                              tooltip: 'เพิ่มเครื่องดื่ม',
                              onPressed: () => _showAddDrinkDialog(context),
                              icon: const Icon(Icons.add_circle_outline),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Grid รายการเครื่องดื่ม (แตะ = เลือก)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: n.drinkPresets.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final d = n.drinkPresets[index];
                            final cnt = n.dailyDrinkCounts[d.id] ?? 0;
                            final selected = _selectedDrinkIndex == index;

                            return _DrinkTile(
                              name: d.name,
                              mlHint: _finalMl(),
                              count: cnt,
                              selected: selected,
                              onTap: () => setState(() => _selectedDrinkIndex = index),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ปุ่ม Add (บันทึก)
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: () async {
                    final ml = _finalMl();
                    if (_selectedDrinkIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('โปรดเลือกเครื่องดื่มก่อน')),
                      );
                      return;
                    }
                    if (ml == null || ml <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('โปรดระบุปริมาณ (ml)')),
                      );
                      return;
                    }
                    final drink = n.drinkPresets[_selectedDrinkIndex!];
                    await n.logDrinkWithMl(drink, ml);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Dialog เพิ่มเครื่องดื่มใหม่ — ชื่ออย่างเดียว
  Future<void> _showAddDrinkDialog(BuildContext context) async {
    final nameCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มเครื่องดื่ม'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtl,
            decoration: const InputDecoration(
              labelText: 'ชื่อเครื่องดื่ม (เช่น น้ำเปล่า ชา...)',
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<HabitNotifier>().addDrinkPreset(nameCtl.text.trim());
                Navigator.pop(context, true);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มเครื่องดื่มแล้ว')));
    }
  }
}

class _DrinkTile extends StatelessWidget {
  final String name;
  final int? mlHint;  // ใช้โชว์เล็ก ๆ ว่าตอนนี้จะบวกกี่ ml
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _DrinkTile({
    required this.name,
    required this.mlHint,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? primaryColor : Colors.grey.shade300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_drink, size: 28),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (mlHint != null)
                    Text('+$mlHint ml',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(999)),
                  child: Text('x$count',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ===== คอมโบฟิลด์: ช่องเดียว (กรอกเอง + ดรอปดาวน์) =====
class _MlComboField extends StatelessWidget {
  final TextEditingController controller;
  final List<int> options;
  final String label;
  final ValueChanged<int?>? onChanged;

  const _MlComboField({
    required this.controller,
    required this.options,
    this.label = 'ปริมาณ (ml)',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: PopupMenuButton<int>(
          tooltip: 'เลือกจากรายการ',
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (v) {
            controller.text = v.toString();
            onChanged?.call(v);
          },
          itemBuilder: (context) => options
              .map((e) => PopupMenuItem<int>(value: e, child: Text('$e ml')))
              .toList(),
        ),
      ),
      onChanged: (_) => onChanged?.call(int.tryParse(controller.text)),
    );
  }
}
