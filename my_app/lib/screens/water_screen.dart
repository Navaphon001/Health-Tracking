import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/habit_notifier.dart';
import '../theme/app_colors.dart';
import '../shared/custom_top_app_bar.dart';

// Water Loading Animation Widget
class WaterLoadingAnimation extends StatefulWidget {
  final double size;
  final Color waterColor;
  final Color borderColor;
  final double waterLevel; // 0.0 to 1.0

  const WaterLoadingAnimation({
    super.key,
    required this.size,
    required this.waterColor,
    required this.borderColor,
    required this.waterLevel,
  });

  @override
  State<WaterLoadingAnimation> createState() => _WaterLoadingAnimationState();
}

class _WaterLoadingAnimationState extends State<WaterLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // ทำให้ช้าลงเพื่อความพริ้วไหว
    )..repeat();

    _waveAnimation = Tween(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear), // ใช้ linear เพื่อการเคลื่อนไหวสม่ำเสมอ
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: widget.borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: WaterPainter(
                waterHeight: widget.waterLevel,
                waterColor: widget.waterColor,
                waveAnimationValue: _waveAnimation.value,
              ),
              child: Center(
                child: Text(
                  '${(widget.waterLevel * 100).round()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: widget.waterLevel > 0.5 ? Colors.white : widget.waterColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WaterPainter extends CustomPainter {
  final double waterHeight;
  final Color waterColor;
  final double waveAnimationValue;

  WaterPainter({
    required this.waterHeight,
    required this.waterColor,
    required this.waveAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;

    // ไม่วาดอะไรถ้าไม่มีน้ำ
    if (waterHeight <= 0) return;

    final wavePaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    // สร้าง path สำหรับน้ำ
    final path = Path();
    
    // กำหนดตำแหน่งผิวน้ำ
    final waterLevel = height * (1 - waterHeight);
    
    // เริ่มจากมุมล่างซ้าย
    path.moveTo(0, height);
    path.lineTo(0, waterLevel);

    // สร้างคลื่นแบบเรียบง่าย มีความโค้งนุ่มนวล
    final waveAmplitude = math.min(8.0, height * 0.03); // ความสูงของคลื่น
    final waveLength = width * 1.5; // ความยาวของคลื่น (ทำให้โค้งกว้างขึ้น)
    
    // สร้างจุดคลื่นสำหรับ cubic bezier curve
    final wavePoints = <Offset>[];
    
    // สร้างจุดคลื่นแบบ smooth
    for (double x = 0; x <= width; x += width / 20) {
      final normalizedX = x / width;
      final waveOffset = math.sin((normalizedX * 2 * math.pi * width / waveLength) + waveAnimationValue) * waveAmplitude;
      wavePoints.add(Offset(x, waterLevel + waveOffset));
    }
    
    // เพิ่มจุดสุดท้าย
    if (wavePoints.last.dx < width) {
      final waveOffset = math.sin((1.0 * 2 * math.pi * width / waveLength) + waveAnimationValue) * waveAmplitude;
      wavePoints.add(Offset(width, waterLevel + waveOffset));
    }

    // วาดเส้นโค้งด้วย cubic bezier เพื่อความนุ่มนวล
    if (wavePoints.isNotEmpty) {
      path.lineTo(wavePoints[0].dx, wavePoints[0].dy);
      
      for (int i = 1; i < wavePoints.length; i++) {
        final current = wavePoints[i];
        final previous = wavePoints[i - 1];
        
        // สร้าง control points สำหรับ cubic bezier
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.3,
          previous.dy
        );
        final controlPoint2 = Offset(
          current.dx - (current.dx - previous.dx) * 0.3,
          current.dy
        );
        
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          current.dx, current.dy
        );
      }
    }

    // ปิด path
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WaterPainter oldDelegate) {
    return oldDelegate.waterHeight != waterHeight ||
        oldDelegate.waterColor != waterColor ||
        oldDelegate.waveAnimationValue != waveAnimationValue;
  }
}

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
    const beverageColor = Colors.blue; // ใช้สีเดียวกันสำหรับทุกเครื่องดื่ม
    
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



  void _showAddBeverageDialog() {
    final nameController = TextEditingController();
    const Color defaultColor = Colors.blue; // Use a default color
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                context.read<HabitNotifier>().addDrinkPreset(name, 250, defaultColor);
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
    final progress = currentAmount / goalAmount;
    
    return Column(
      children: [
        // Water Loading Animation Circle
        WaterLoadingAnimation(
          size: 200,
          waterColor: const Color(0xFF2196F3),
          borderColor: const Color(0xFF42A5F5),
          waterLevel: progress.clamp(0.0, 1.0),
        ),
        const SizedBox(height: 20),
        // Amount text below
        Text(
          '$currentAmount',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '/$goalAmount mL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
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
                        
                        // Action Button  
                        SizedBox(
                          width: double.infinity,
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