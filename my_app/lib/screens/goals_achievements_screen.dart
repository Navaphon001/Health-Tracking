import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/goal_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';

class GoalsAchievementsScreen extends StatefulWidget {
  final bool? fromSettings;
  
  const GoalsAchievementsScreen({super.key, this.fromSettings});

  @override
  State<GoalsAchievementsScreen> createState() => _GoalsAchievementsScreenState();
}

class _GoalsAchievementsScreenState extends State<GoalsAchievementsScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    // ตรวจสอบว่ามาจากการ navigate ปกติหรือไม่ (เช่น จากหน้า Settings)
    final canPop = Navigator.of(context).canPop();
    
    // ถ้าเข้ามาจาก Settings (fromSettings == true) หรือมี canPop ให้ซ่อน profile icon
    // ถ้าเข้ามาจาก NavBar (fromSettings == null หรือ false) ให้แสดง profile icon
    final shouldShowProfileIcon = widget.fromSettings != true && !canPop;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomTopAppBar(
        title: t.goalAndAchievement,
        automaticallyImplyLeading: canPop,
        showProfileIcon: shouldShowProfileIcon,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Goals Section
            Text(
              t.activeGoals,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<GoalProvider>(
              builder: (context, goalProvider, child) {
                final activeGoals = goalProvider.activeGoals;
                return Container(
                  height: 180,
                  child: activeGoals.isEmpty
                      ? _buildEmptyGoalsCard()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: activeGoals.length + 1, // +1 for add card
                          itemBuilder: (context, index) {
                            if (index == activeGoals.length) {
                              return _buildAddGoalCard();
                            }
                            return _buildActiveGoalCard(activeGoals[index]);
                          },
                        ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Achievements Section
            Text(
              t.achievements,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AchievementProvider>(
              builder: (context, achievementProvider, child) {
                final achievements = achievementProvider.achievements;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(achievements[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGoalsCard() {
    return GestureDetector(
      onTap: () => _showAddGoalDialog(),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                size: 30,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).addYourFirstGoal,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGoalCard() {
    return GestureDetector(
      onTap: () => _showAddGoalDialog(),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).addGoal,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGoalCard(Goal goal) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.gradientLightEnd.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _getCategoryIcon(goal.category),
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (goal.targetValue != null && goal.unit != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${goal.targetValue} ${goal.unit}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _showDeleteGoalDialog(goal),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final hasProgress = achievement.isInProgress;
    final isCompleted = achievement.isUnlocked && !achievement.isInProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked 
            ? Colors.grey.shade300  // More opaque background for incomplete achievements
            : Theme.of(context).cardColor,
        border: Border.all(
          color: isLocked 
              ? Colors.grey.shade400  // Darker border for incomplete achievements
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Share button for completed achievements (top-right corner)
          if (isCompleted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () => _showAchievementShareBottomSheet(achievement),
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  tooltip: AppLocalizations.of(context).share,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ),
          
          // Centered content layout
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon/Image centered in the middle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLocked 
                        ? Colors.grey.shade400  // More opaque background for incomplete achievements
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      achievement.iconPath,
                      style: TextStyle(
                        fontSize: 24,
                        color: isLocked 
                            ? Colors.grey.shade600  // Dimmed icon color for incomplete achievements
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Title
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLocked 
                        ? Colors.grey.shade600  // Dimmed text color for incomplete achievements
                        : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Progress bar (only if in progress)
                if (hasProgress) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${achievement.currentProgress}/${achievement.maxProgress}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isLocked 
                          ? Colors.grey.shade600  // Dimmed progress text for incomplete achievements
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: isLocked 
                        ? Colors.grey.shade400  // Dimmed progress background for incomplete achievements
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLocked 
                          ? Colors.grey.shade500  // Dimmed progress color for incomplete achievements
                          : Theme.of(context).colorScheme.primary
                    ),
                    minHeight: 3,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'exercise':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
      case 'weight':
        return Icons.monitor_weight;
      default:
        return Icons.flag;
    }
  }

  void _showAddGoalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalBottomSheet(),
    );
  }

  void _showDeleteGoalDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteGoal),
        content: Text(AppLocalizations.of(context).confirmDeleteGoal(goal.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalProvider>().removeGoal(goal.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).goalDeletedSuccessfully),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  // Achievement sharing functionality
  void _showAchievementShareBottomSheet(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                AppLocalizations.of(context).shareAchievement,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            
            // Share options (only image share)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildAchievementShareOption(
                    icon: Icons.image,
                    title: AppLocalizations.of(context).shareAchievement,
                    subtitle: 'แชร์ achievement',
                    color: Colors.green,
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareAchievementAsImage(achievement);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Note: text sharing removed; only image sharing is supported now.

  // Build a shareable achievement image widget
  Widget _buildShareableAchievementCard(Achievement achievement) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Health Tracking App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Achievement Badge
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                achievement.iconPath,
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Achievement Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              '🏆 Achievement Unlocked!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Achievement Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              achievement.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Achievement Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              achievement.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Motivational Message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Keep up the great work! 💪',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Share achievement as image
  Future<void> _shareAchievementAsImage(Achievement achievement) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('กำลังสร้างรูปภาพ...'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      // Capture the achievement card as image
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        _buildShareableAchievementCard(achievement),
        context: context,
        pixelRatio: 2.0,
      );

      if (imageBytes != null) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/achievement_${DateTime.now().millisecondsSinceEpoch}.png';
        
        // Save image to file
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // Share the image with text
        final shareText = '''
🏆 Achievement Unlocked!

${achievement.iconPath} ${achievement.title}

${achievement.description}

Just completed this challenge in Health Tracking App! 💪

#HealthTracking #Achievement #Wellness
        '''.trim();

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
        );

        // Clean up temporary file after a delay
        Future.delayed(const Duration(seconds: 10), () {
          if (imageFile.existsSync()) {
            imageFile.deleteSync();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการสร้างรูปภาพ: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            action: SnackBarAction(
              label: 'ตกลง',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

class _AddGoalBottomSheet extends StatefulWidget {
  @override
  _AddGoalBottomSheetState createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<_AddGoalBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedUnit = '';
  DateTime? _targetDate;

  List<Map<String, String>> _getLocalizedCategories(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      {'value': 'water', 'label': t.drinkWater, 'unit': t.glasses},
      {'value': 'exercise', 'label': t.exercise, 'unit': t.minutes},
      {'value': 'sleep', 'label': t.sleepGoal, 'unit': t.hours},
      {'value': 'weight', 'label': t.weightGoal, 'unit': t.kg},
      {'value': 'general', 'label': t.general, 'unit': ''},
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedUnit = 'glasses'; // Default unit will be updated when dialog is shown
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).addGoal,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).goalTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).description,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).category,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              items: _getLocalizedCategories(context).map((category) {
                return DropdownMenuItem<String>(
                  value: category['value'],
                  child: Text(category['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _selectedUnit = _getLocalizedCategories(context).firstWhere(
                    (cat) => cat['value'] == value,
                  )['unit']!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Target value (if applicable)
            if (_selectedUnit.isNotEmpty)
              TextField(
                controller: _targetValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).targetValue(_selectedUnit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            if (_selectedUnit.isNotEmpty) const SizedBox(height: 16),

            // Target date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _targetDate == null 
                    ? 'Select Target Date (Optional)' 
                    : 'Target Date: ${_formatDate(_targetDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _targetDate = date);
                }
              },
            ),
            const SizedBox(height: 24),

            // Add button (gradient themed)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.gradientLightEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _addGoal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).addGoal,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addGoal() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseEnterGoalTitle)),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseEnterDescription)),
      );
      return;
    }

    final goalProvider = context.read<GoalProvider>();
    
    double? targetValue;
    if (_targetValueController.text.isNotEmpty) {
      targetValue = double.tryParse(_targetValueController.text);
    }

    final goal = goalProvider.createGoal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      targetDate: _targetDate,
      targetValue: targetValue,
      unit: _selectedUnit.isNotEmpty ? _selectedUnit : null,
    );

    goalProvider.addGoal(goal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).goalAddedSuccessfully),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
