import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';
import '../models/nutrition.dart';

class MealLoggingScreen extends StatefulWidget {
  const MealLoggingScreen({super.key});

  @override
  State<MealLoggingScreen> createState() => _MealLoggingScreenState();
}

class _MealLoggingScreenState extends State<MealLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  
  MealType _selectedMealType = MealType.breakfast;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Nutrition? _lastSavedNutrition;
  bool _isSaving = false;
  // In-memory drafts per meal type for the current day. Keys: foodName, imagePath, nutrition
  final Map<MealType, Map<String, dynamic>> _mealDrafts = {};
  DateTime _draftDate = DateTime.now();

  

  // Build a list of nutrient widgets from a Nutrition object. Supports arbitrary items.
  List<Widget> _buildNutritionWidgets(Nutrition n) {
    final items = <MapEntry<String, Map<String, dynamic>>>[];

    // Calories (kcal)
    items.add(MapEntry('Calories', {'value': n.calories, 'unit': 'kcal'}));
    // Macronutrients in grams
    items.add(MapEntry('Carbs', {'value': n.carbs, 'unit': 'g'}));
    items.add(MapEntry('Fat', {'value': n.fat, 'unit': 'g'}));
    items.add(MapEntry('Protein', {'value': n.protein, 'unit': 'g'}));
    // Optional others if available
    if (n.fiber != null) items.add(MapEntry('Fiber', {'value': n.fiber, 'unit': 'g'}));
    if (n.sugar != null) items.add(MapEntry('Sugar', {'value': n.sugar, 'unit': 'g'}));

    // Build widgets using Wrap-friendly blocks
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final label = items[i].key;
      final value = items[i].value['value'] as double?;
      final unit = items[i].value['unit'] as String;
      final color = AppColors.tagColors[i % AppColors.tagColors.length];

        // Pastel rounded card style (matches the attached mock)
        final bgColor = color.withOpacity(0.12);
        widgets.add(
        Card(
          elevation: 0,
          color: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(label, textAlign: TextAlign.left, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Statistics',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 6),
                Text(
                  value != null ? '${value.toStringAsFixed(0)} $unit' : '-',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ));
    }

    return widgets;
  }

  void _clearForm() {
    _foodNameController.clear();
    setState(() {
      _selectedImage = null;
      _lastSavedNutrition = null;
    });
    // reset form validation state if needed
    _formKey.currentState?.reset();
  }

  void _clearDraftsIfNewDay() {
    final now = DateTime.now();
    if (now.year != _draftDate.year || now.month != _draftDate.month || now.day != _draftDate.day) {
      _mealDrafts.clear();
      _draftDate = now;
      // also clear current form for the new day
      _clearForm();
    }
  }

  void _saveDraftForMeal(MealType type) {
    _mealDrafts[type] = {
      'foodName': _foodNameController.text.trim(),
      'imagePath': _selectedImage?.path,
      'nutrition': _lastSavedNutrition,
    };
  }

  void _loadDraftForMeal(MealType type) {
    final data = _mealDrafts[type];
    if (data != null) {
      _foodNameController.text = data['foodName'] ?? '';
      final path = data['imagePath'] as String?;
      setState(() {
        _selectedImage = path != null ? File(path) : null;
        _lastSavedNutrition = data['nutrition'] as Nutrition?;
      });
    } else {
      // no draft -> clear form
      _clearForm();
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  String _getMealTypeName(MealType type, AppLocalizations t) {
    switch (type) {
      case MealType.breakfast:
        return t.breakfast;
      case MealType.lunch:
        return t.lunch;
      case MealType.dinner:
        return t.dinner;
      case MealType.snack:
        return t.snack;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).imageSelectionError(e.toString()))),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(t.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(t.deletePhoto),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      try {
        // สร้าง meal object
        final meal = Meal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          foodName: _foodNameController.text.trim(),
          mealType: _selectedMealType,
          imageUrl: _selectedImage?.path,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock save: simulate a short delay and then set mock nutrition data
        setState(() { _isSaving = true; });
        await Future.delayed(const Duration(milliseconds: 700));
        
        // Generate random calories between 150-800 based on food name for consistency
        final random = Random(meal.foodName.hashCode); // Use hashCode as seed for consistency
        final randomCalories = 150 + random.nextInt(651); // 150-800 range
        
        // Create a mocked Nutrition entry (values are example placeholders)
        final mockNutrition = Nutrition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          foodName: meal.foodName,
          calories: randomCalories.toDouble(),
          protein: 12.0 + (meal.foodName.length % 5),
          carbs: 30.0 + (meal.foodName.length % 7),
          fat: 10.0 + (meal.foodName.length % 4),
          fiber: 3.0,
          sugar: 5.0,
          lastUpdated: DateTime.now(),
        );
        setState(() {
          _lastSavedNutrition = mockNutrition;
          _isSaving = false;
        });
        // keep this saved data as a draft for the current meal (in-memory)
        _saveDraftForMeal(_selectedMealType);

        // แสดงข้อความสำเร็จ
        if (mounted) {
          final t = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.mealDataSavedSuccessfully)),
          );

          // หลังบันทึก: แสดง nutrition card บนหน้านี้ (ไม่ปิดหน้า)
        }
      } catch (e) {
        // แสดงข้อความผิดพลาด
        if (mounted) {
          final t = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.errorOccurredWithDetails(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ensure drafts reset on a new day
    _clearDraftsIfNewDay();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context);
    
    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) {
        return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomTopAppBar(
        title: t.mealLogging,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: colorScheme.surface,
          shadowColor: Colors.black.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Meal Type Selection (on its own Card)
              Text(
                t.selectMealTime,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    children: MealType.values.map((type) {
                      final isSelected = _selectedMealType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedMealType != type) {
                                // save current draft before switching
                                _saveDraftForMeal(_selectedMealType);
                                // load the draft for the chosen meal (or clear if none)
                                _loadDraftForMeal(type);
                              }
                              setState(() {
                                _selectedMealType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.lightGray,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                _getMealTypeName(type, t),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Food Name Input
              Text(
                t.foodName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Food name on its own Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        hintText: t.enterFoodName,
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.pleaseEnterFoodName;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image Area on its own Card
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surface,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 30,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.mealPhoto,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.addPhoto,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nutrition card (appears only after save)
              if (_lastSavedNutrition != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: colorScheme.surface,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row with Nutrition on left and calories on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).nutrition,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context).totalCalories((_lastSavedNutrition!.calories ?? 0).round()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Use a responsive two-column layout that looks like statistic cards
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Force two columns whenever we have at least two items
                              final nutrientChildren = _buildNutritionWidgets(_lastSavedNutrition!);
                              final columns = nutrientChildren.length >= 2 ? 2 : 1;
                              const spacing = 12.0;
                              final maxCardWidth = 160.0;
                              final available = constraints.maxWidth - spacing * (columns - 1);
                              final calculated = available / columns;
                              final itemWidth = calculated > maxCardWidth ? maxCardWidth : calculated;
                              return Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                spacing: spacing,
                                runSpacing: 12,
                                children: nutrientChildren.map((w) {
                                  return SizedBox(width: itemWidth, child: w);
                                }).toList(),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.gradientLightEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            t.saveMeal,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}