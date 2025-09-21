import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class GoalsAchievementsScreen extends StatefulWidget {
  const GoalsAchievementsScreen({super.key});

  @override
  State<GoalsAchievementsScreen> createState() => _GoalsAchievementsScreenState();
}

class _GoalsAchievementsScreenState extends State<GoalsAchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.goalAndAchievement,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Goals Section
            Text(
              'Active Goals',
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
              'Achievements',
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
              'Add your first goal',
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
              'Add Goal',
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked 
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).cardColor,
        border: Border.all(
          color: isLocked 
              ? Theme.of(context).dividerColor 
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Icon and Title
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLocked 
                        ? Colors.grey.shade200 
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      achievement.iconPath,
                      style: TextStyle(
                        fontSize: 24,
                        color: isLocked ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLocked 
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Progress bar (only if in progress)
          if (hasProgress) ...[
            const SizedBox(height: 8),
            Column(
              children: [
                Text(
                  '${achievement.currentProgress}/${achievement.maxProgress}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: achievement.progressPercentage,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  minHeight: 3,
                ),
              ],
            ),
          ],
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
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalProvider>().removeGoal(goal.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

  final List<Map<String, String>> _categories = [
    {'value': 'water', 'label': 'ดื่มน้ำ', 'unit': 'glasses'},
    {'value': 'exercise', 'label': 'ออกกำลังกาย', 'unit': 'minutes'},
    {'value': 'sleep', 'label': 'นอนหลับ', 'unit': 'hours'},
    {'value': 'weight', 'label': 'น้ำหนัก', 'unit': 'kg'},
    {'value': 'general', 'label': 'ทั่วไป', 'unit': ''},
  ];

  @override
  void initState() {
    super.initState();
    _selectedUnit = _categories.first['unit']!;
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
                  'Add New Goal',
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
                labelText: 'Goal Title',
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
                labelText: 'Description',
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
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['value'],
                  child: Text(category['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _selectedUnit = _categories.firstWhere(
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
                  labelText: 'Target Value ($_selectedUnit)',
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

            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
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
        content: const Text('Goal added successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
