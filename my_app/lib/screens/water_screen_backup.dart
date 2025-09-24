import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/habit_notifier.dart';
import '../theme/app_colors.dart';
import '../shared/custom_top_app_bar.dart';

// Water intake entry for tracking individual drinks
class WaterIntakeEntry {
  final int amount;
  final Color color;
  final String beverageName;
  final DateTime timestamp;
  
  WaterIntakeEntry({
    required this.amount,
    required this.color,
    required this.beverageName,
    required this.timestamp,
  });
}

// Water segment data class
class WaterSegment {
  final double percentage;
  final Color color;
  
  WaterSegment({required this.percentage, required this.color});
}

// Custom painter for segmented circle
class SegmentedCirclePainter extends CustomPainter {
  final List<WaterSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;
  
  SegmentedCirclePainter({
    required this.segments,
    required this.strokeWidth,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw segments
    double startAngle = -math.pi / 2; // Start from top
    
    for (final segment in segments) {
      final sweepAngle = 2 * math.pi * segment.percentage;
      
      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
      
      startAngle += sweepAngle;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedAmount = '250';
  DrinkPreset? _selectedBeverage;

  final List<String> _amountOptions = ['100', '150', '200', '250', '300', '350', '400', '500'];
  
  // เก็บรายการการดื่มสำหรับ testing (in-memory)
  final List<WaterIntakeEntry> _todayIntakes = [];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = _selectedAmount;
    // ไม่ต้องเชื่อมกับ SQLite สำหรับ testing
  }

  void _addWaterIntake() {
    final amount = int.tryParse(_amountController.text.isNotEmpty 
        ? _amountController.text 
        : _selectedAmount);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterAmount),
        ),
      );
      return;
    }

    // เตรียมข้อมูลเครื่องดื่มและสี
    final beverageName = _selectedBeverage?.name ?? 'Water';
    final beverageColor = _selectedBeverage != null 
        ? Color(_selectedBeverage!.color) 
        : AppColors.tagColors[0]; // สีเริ่มต้นสำหรับน้ำธรรมดา
    
    // เก็บรายการการดื่มพร้อมสี
    _todayIntakes.add(WaterIntakeEntry(
      amount: amount,
      color: beverageColor,
      beverageName: beverageName,
      timestamp: DateTime.now(),
    ));
    
    // บันทึกข้อมูลรวมใน HabitNotifier
    final notifier = context.read<HabitNotifier>();
    notifier.dailyWaterMl += amount;
    notifier.dailyWaterCount += 1;
    
    // Reset form
    setState(() {
      _selectedBeverage = null;
      _amountController.text = _selectedAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).beverageAdded),
      ),
    );
  }

  // Temporary reset method for testing segmented circle feature
  void _resetWaterIntake() async {
    final notifier = context.read<HabitNotifier>();
    
    // Reset water data
    notifier.dailyWaterMl = 0;
    notifier.dailyWaterCount = 0;
    
    // ล้างรายการการดื่มวันนี้
    _todayIntakes.clear();
    
    // Reset form
    setState(() {
      _selectedBeverage = null;
      _amountController.text = _selectedAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Water intake reset (TEST MODE)'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddBeverageDialog() {
    final nameController = TextEditingController();
    Color selectedColor = AppColors.tagColors[0]; // Default to first color
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('เพิ่มเครื่องดื่มใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเครื่องดื่ม',
                  hintText: 'เช่น นมเย็น, ชาเขียว',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'เลือกสี Tag:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.tagColors.map((color) {
                  final isSelected = selectedColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                
                if (name.isNotEmpty) {
                  context.read<HabitNotifier>().addDrinkPreset(name, 250, selectedColor);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เพิ่ม $name เรียบร้อยแล้ว')),
                  );
                }
              },
              child: Text(AppLocalizations.of(context).add),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(DrinkPreset preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบเครื่องดื่ม'),
        content: Text('คุณต้องการลบ "${preset.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // If the deleted beverage is currently selected, deselect it
              if (_selectedBeverage?.id == preset.id) {
                setState(() {
                  _selectedBeverage = null;
                  _selectedAmount = '250';
                  _amountController.text = _selectedAmount;
                });
              }
              
              await context.read<HabitNotifier>().deleteDrinkPreset(preset.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบ ${preset.name} เรียบร้อยแล้ว')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Widget _buildBeverageCard(DrinkPreset preset) {
    final isSelected = _selectedBeverage?.id == preset.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // If already selected, deselect it
            _selectedBeverage = null;
            _selectedAmount = '250'; // Reset to default
            _amountController.text = _selectedAmount;
          } else {
            // Select the beverage
            _selectedBeverage = preset;
            _selectedAmount = preset.ml.toString();
            _amountController.text = _selectedAmount;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Main content - centered
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0, left: 8.0, right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_drink,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Color Tag Capsule
                    Container(
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(preset.color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button in top-right corner
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmDialog(preset),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBeverageCard() {
    return GestureDetector(
      onTap: _showAddBeverageDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(int currentAmount, int goalAmount) {
    return Consumer<HabitNotifier>(
      builder: (context, habitNotifier, child) {
        // Get today's water entries to calculate segments
        final segments = _calculateWaterSegments(habitNotifier, goalAmount);
        
        return Container(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: SegmentedCirclePainter(
                    segments: segments,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey[300]!,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current amount - large text in center
                  Text(
                    '$currentAmount',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Goal amount - small text below
                  Text(
                    '/ ${goalAmount}ml',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<WaterSegment> _calculateWaterSegments(HabitNotifier habitNotifier, int goalAmount) {
    final segments = <WaterSegment>[];
    
    if (goalAmount <= 0 || _todayIntakes.isEmpty) return segments;
    
    // รวมปริมาณการดื่มตามสี
    final colorAmountMap = <int, int>{}; // color.value -> total amount
    
    for (final intake in _todayIntakes) {
      final colorValue = intake.color.value;
      colorAmountMap[colorValue] = (colorAmountMap[colorValue] ?? 0) + intake.amount;
    }
    
    // แปลงเป็น segments ตามสัดส่วน
    double totalSegmentPercentage = 0.0;
    
    for (final entry in colorAmountMap.entries) {
      final colorValue = entry.key;
      final amount = entry.value;
      final color = Color(colorValue);
      final percentage = (amount / goalAmount).clamp(0.0, 1.0);
      
      if (percentage > 0 && totalSegmentPercentage < 1.0) {
        final adjustedPercentage = math.min(percentage, 1.0 - totalSegmentPercentage);
        segments.add(WaterSegment(
          percentage: adjustedPercentage,
          color: color,
        ));
        totalSegmentPercentage += adjustedPercentage;
      }
      
      if (totalSegmentPercentage >= 1.0) break;
    }
    
    return segments;
  }

  Widget _buildBeverageGrid() {
    return Consumer<HabitNotifier>(
      builder: (context, notifier, child) {
        final presets = notifier.drinkPresets;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: presets.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            if (index == presets.length) {
              return _buildAddBeverageCard();
            }
            return _buildBeverageCard(presets[index]);
          },
        );
      },
    );
  }

  Widget _buildAmountInput() {
    return DropdownButtonFormField<String>(
      value: _selectedAmount,
      onChanged: (value) {
        setState(() {
          _selectedAmount = value!;
          _amountController.text = _selectedAmount;
        });
      },
      decoration: InputDecoration(
        labelText: 'Select Amount',
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: _amountOptions.map((amount) {
        return DropdownMenuItem<String>(
          value: amount,
          child: Text('$amount ml'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.waterIntakeTitle,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<HabitNotifier>(
        builder: (context, notifier, child) {
          final totalAmount = notifier.dailyWaterMl;
          const goalAmount = 2000; // Default goal: 2000ml

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Progress Circle
                _buildProgressCircle(totalAmount, goalAmount),
                
                const SizedBox(height: 32),
                
                // Main Card with all controls
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              Icons.local_drink,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Water Intake',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Selected Beverage Info
                        if (_selectedBeverage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_drink, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected: ${_selectedBeverage!.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(_selectedBeverage!.color),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Section: Choose Beverage
                        Text(
                          'Choose Beverage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Beverage Selection Grid
                        _buildBeverageGrid(),
                        
                        const SizedBox(height: 24),
                        
                        // Section: Amount
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Amount Input
                        _buildAmountInput(),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            // Reset Button (temporary for testing)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _resetWaterIntake,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[50],
                                  foregroundColor: Colors.red[600],
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.red[200]!),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Save Button
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _addWaterIntake,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 2,
                                  shadowColor: AppColors.primary.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  t.save,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}