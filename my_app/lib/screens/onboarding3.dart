import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class Onboarding3 extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding3({
    super.key,
    this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    t.skip,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration/Icon
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Title
                    Text(
                      t.analyzeProgressTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      t.analyzeProgressDesc,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Get Started button (last screen)
            Padding(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    t.getStarted,
                    style: TextStyle(
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
    );
  }
}