import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/habit_notifier.dart';
import '../theme/app_colors.dart';

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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = _selectedAmount;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final n = context.read<HabitNotifier>();
      // Reset เพื่อเริ่มนับใหม่
      n.dailyWaterMl = 0;
      n.dailyWaterCount = 0;
      await n.fetchDailyWaterIntake();
    });
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

    // ใช้เครื่องดื่มที่เลือก หรือสร้าง DrinkPreset สำหรับน้ำธรรมดา
    final preset = _selectedBeverage ?? DrinkPreset(
      id: 'water_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Water',
      ml: amount,
    );

    // บันทึกผ่าน HabitNotifier (ส่ง amount ที่ผู้ใช้กรอก)
    context.read<HabitNotifier>().logDrinkWithMl(preset, amount);
    
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มเครื่องดื่มใหม่'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'ชื่อเครื่องดื่ม',
            hintText: 'เช่น นมเย็น, ชาเขียว',
          ),
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
                context.read<HabitNotifier>().addDrinkPreset(name, 250);
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
    final progress = goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentAmount/${goalAmount}ml',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeverageGrid() {
    final t = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.selectBeverage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: _showAddBeverageDialog,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<HabitNotifier>(
            builder: (context, notifier, child) {
              final presets = notifier.drinkPresets;
              
              // Calculate grid dimensions - show exactly 3 rows for better visibility
              final totalItems = presets.length + 1; // +1 for add button
              final maxVisibleRows = 3;
              final gridHeight = maxVisibleRows * 80.0 + (maxVisibleRows - 1) * 12.0; // 3 rows * 80 height + 2 spacing
              
              return Container(
                height: gridHeight, // Fixed height for 3 rows
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(), // Enable scrolling
                  itemCount: totalItems,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    if (index == presets.length) {
                      // Add button
                      return _buildAddBeverageCard();
                    } else {
                      // Beverage preset
                      final preset = presets[index];
                      return _buildBeverageCard(preset);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'กรอกปริมาณ ml',
        suffixText: 'ml',
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onSelected: (String value) {
            setState(() {
              _selectedAmount = value;
              _amountController.text = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return _amountOptions.map<PopupMenuEntry<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text('$value ml'),
              );
            }).toList();
          },
        ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(t.waterIntakeTitle, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/settings'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
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
                
                const SizedBox(height: 30),
                
                // Amount Input
                Center(
                  child: SizedBox(
                    width: 140,
                    child: _buildAmountInput(),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Beverage Selection Grid
                _buildBeverageGrid(),
                
                const SizedBox(height: 30),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addWaterIntake,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
          );
        },
      ),
    );
  }
}
