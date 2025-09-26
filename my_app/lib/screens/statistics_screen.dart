import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

import '../charts/chart_point.dart';
import '../charts/trend_line_chart.dart';
import '../services/habit_local_repository.dart';
import '../providers/habit_notifier.dart';
import '../l10n/app_localizations.dart';
import '../shared/custom_top_app_bar.dart';
import '../theme/app_colors.dart';

enum TimePeriod { daily, weekly, monthly }

class StatisticsScreen extends StatefulWidget {
  final HabitLocalRepository repo;

  const StatisticsScreen({super.key, required this.repo});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.daily;

  int get _days {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return 7;
      case TimePeriod.weekly:
        return 28; // 4 weeks
      case TimePeriod.monthly:
        return 90; // 3 months
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    // goal เดิมเป็น "แก้ว" -> แปลงเป็นมล. (สมมติ 1 แก้ว = 250 มล.)
    final waterGlassesGoal =
        context.select<HabitNotifier, int>((n) => n.dailyWaterGoal);
    final double waterGoalMl = ((waterGlassesGoal > 0
                ? waterGlassesGoal * 250
                : 2000) // fallback เป้าหมาย 2,000 มล.
            )
        .toDouble();

    const double exerciseKcalGoal = 300; // เป้าหมาย kcal/วัน (ตั้งค่าได้ตามต้องการ)

    return Scaffold(
      appBar: CustomTopAppBar(
        title: t.statistics,
        automaticallyImplyLeading: true,
        showProfileIcon: false,
      ),
      body: Column(
        children: [
          // Time Period Selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPeriodTab(t.daily, TimePeriod.daily),
                _buildPeriodTab(t.weekly, TimePeriod.weekly),
                _buildPeriodTab(t.monthly, TimePeriod.monthly),
              ],
            ),
          ),
          
          // Statistics Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildInfoCard(
                  title: t.sleepHours,
                  icon: Icons.bedtime,
                  iconColor: Colors.purple,
                  future: widget.repo.fetchSleepHoursSeries(days: _days),
                  unit: t.hours,
                  goal: 8,
                  formatValue: (value) => '${value.toStringAsFixed(1)} ${t.hours}',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: t.waterIntakeML,
                  icon: Icons.water_drop,
                  iconColor: AppColors.primary,
                  future: widget.repo.fetchWaterMlSeries(days: _days),
                  unit: t.milliliters,
                  goal: waterGoalMl,
                  formatValue: (value) => '${value.toInt()} ${t.milliliters}',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: t.exerciseCalories,
                  icon: Icons.fitness_center,
                  iconColor: Colors.orange,
                  future: widget.repo.fetchExerciseCaloriesSeries(days: _days),
                  unit: t.calories,
                  goal: exerciseKcalGoal,
                  formatValue: (value) => '${value.toInt()} ${t.calories}',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Future<List<ChartPoint>> future,
    required String unit,
    required double goal,
    required String Function(double) formatValue,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              iconColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          _getPeriodDescription(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _showShareBottomSheet(context, title, future, unit, goal, formatValue),
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      tooltip: AppLocalizations.of(context).share,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Chart and Stats
              FutureBuilder<List<ChartPoint>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          '${AppLocalizations.of(context).errorOccurred}: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    );
                  }
                  
                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).noDataAvailable,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final latest = data.isNotEmpty ? data.last.value : 0.0;
                  final average = data.isNotEmpty 
                      ? data.map((e) => e.value).reduce((a, b) => a + b) / data.length 
                      : 0.0;
                  
                  return Column(
                    children: [
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              AppLocalizations.of(context).latest,
                              formatValue(latest),
                              iconColor,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              AppLocalizations.of(context).average,
                              formatValue(average),
                              Colors.grey[600]!,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              AppLocalizations.of(context).goalLabel,
                              formatValue(goal),
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Chart
                      SizedBox(
                        height: 180,
                        child: TrendLineChart(
                          data: data,
                          unit: unit,
                          goal: goal,
                          curved: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getPeriodDescription() {
    final t = AppLocalizations.of(context);
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return '7 ${t.daily.toLowerCase()}';
      case TimePeriod.weekly:
        return '4 ${t.weekly.toLowerCase()}';
      case TimePeriod.monthly:
        return '3 ${t.monthly.toLowerCase()}';
    }
  }

  // Share functionality methods
  void _showShareBottomSheet(
    BuildContext context,
    String title,
    Future<List<ChartPoint>> future,
    String unit,
    double goal,
    String Function(double) formatValue,
  ) {
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
                '${AppLocalizations.of(context).shareData} $title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            
            // Share options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildShareOption(
                    icon: Icons.picture_as_pdf,
                    title: AppLocalizations.of(context).exportToPDF,
                    subtitle: AppLocalizations.of(context).saveDataAsPDF,
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      await _generateAndSharePDF(title, future, unit, goal, formatValue);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShareOption(
                    icon: Icons.share,
                    title: AppLocalizations.of(context).shareData,
                    subtitle: AppLocalizations.of(context).shareToOtherApps,
                    color: AppColors.primary,
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareData(title, future, unit, goal, formatValue);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShareOption(
                    icon: Icons.copy,
                    title: AppLocalizations.of(context).copyText,
                    subtitle: AppLocalizations.of(context).copyToClipboard,
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      await _copyData(title, future, unit, goal, formatValue);
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

  Widget _buildShareOption({
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

  Future<void> _shareData(
    String title,
    Future<List<ChartPoint>> future,
    String unit,
    double goal,
    String Function(double) formatValue,
  ) async {
    try {
      final data = await future;
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).noDataToShare)),
          );
        }
        return;
      }
      
      final latest = data.last.value;
      final average = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
      final period = _getPeriodDescription();
      
      final shareText = '''
📊 $title ($period)

📈 ล่าสุด: ${formatValue(latest)}
📊 เฉลี่ย: ${formatValue(average)}
🎯 เป้าหมาย: ${formatValue(goal)}

สร้างโดย Health Tracking App
      '''.trim();
      
      final result = await Share.share(shareText);
      
      // Handle share result
      if (result.status == ShareResultStatus.unavailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่มีแอพที่รองรับการแชร์ในอุปกรณ์นี้'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // More specific error handling
        String errorMessage;
        if (e.toString().contains('MissingPluginException')) {
          errorMessage = 'การแชร์ไม่รองรับในโหมดนี้ (โปรดทดสอบบนอุปกรณ์จริง)';
        } else if (e.toString().contains('No implementation found')) {
          errorMessage = 'ไม่พบแอพที่รองรับการแชร์';
        } else {
          errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  Future<void> _generateAndSharePDF(
    String title,
    Future<List<ChartPoint>> future,
    String unit,
    double goal,
    String Function(double) formatValue,
  ) async {
    try {
      final data = await future;
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).noDataToPDF)),
          );
        }
        return;
      }
      
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      
      final pdf = pw.Document();
      final latest = data.last.value;
      final average = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
      final period = _getPeriodDescription();
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0ABAB5'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Health Tracking Report',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              title,
                              style: pw.TextStyle(
                                fontSize: 18,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 24),
                
                // Period info
                pw.Text(
                  'ช่วงเวลา: $period',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Statistics
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Column(
                            children: [
                              pw.Text(
                                'ล่าสุด',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(formatValue(latest)),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'เฉลี่ย',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(formatValue(average)),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'เป้าหมาย',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(formatValue(goal)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 24),
                
                // Data table
                pw.Text(
                  'ข้อมูลรายละเอียด',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                
                pw.SizedBox(height: 12),
                
                pw.TableHelper.fromTextArray(
                  headers: ['วันที่', 'ค่า ($unit)'],
                  data: data.map((point) => [
                    '${point.day.day}/${point.day.month}/${point.day.year}',
                    formatValue(point.value),
                  ]).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.center,
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'สร้างโดย Health Tracking App • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Generate PDF bytes
      final Uint8List pdfBytes = await pdf.save();
      
      // Hide loading
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Share PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'health_report_${title.toLowerCase().replaceAll(' ', '_')}.pdf',
      );
      
    } catch (e) {
      // Hide loading if still showing
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorCreatingPDF(e.toString()))),
        );
      }
    }
  }

  Future<void> _copyData(
    String title,
    Future<List<ChartPoint>> future,
    String unit,
    double goal,
    String Function(double) formatValue,
  ) async {
    try {
      final data = await future;
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).noDataToCopy)),
          );
        }
        return;
      }
      
      final latest = data.last.value;
      final average = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
      final period = _getPeriodDescription();
      
      final shareText = '''
📊 $title ($period)

📈 ล่าสุด: ${formatValue(latest)}
📊 เฉลี่ย: ${formatValue(average)}
🎯 เป้าหมาย: ${formatValue(goal)}

สร้างโดย Health Tracking App
      '''.trim();
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: shareText));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).copiedSuccessfully),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorCopying(e.toString())),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Future<List<ChartPoint>> future;
  final Widget Function(List<ChartPoint>) childBuilder;

  const SectionCard({
    super.key,
    required this.title,
    required this.future,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: FutureBuilder<List<ChartPoint>>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('ผิดพลาด: ${snap.error}'));
                  }
                  final data = snap.data ?? const <ChartPoint>[];
                  if (data.isEmpty) {
                    return const Center(child: Text('ยังไม่มีข้อมูล'));
                  }
                  return childBuilder(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}