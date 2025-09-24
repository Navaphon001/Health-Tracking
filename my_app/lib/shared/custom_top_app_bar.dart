import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final bool automaticallyImplyLeading;
  final bool showProfileIcon;

  const CustomTopAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.automaticallyImplyLeading = false,
    this.showProfileIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          child: Stack(
            children: [
              // Custom curved shape with concave corners
              Positioned.fill(
                child: CustomPaint(
                  painter: CurvedAppBarPainter(),
                ),
              ),
              // Content positioned in the middle area
              Positioned(
                left: 0,
                right: 0,
                top: 20, // Move content down to center vertically
                bottom: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      // Back button if needed
                      if (automaticallyImplyLeading && Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      
                      // Title centered
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Profile button with better contrast (conditionally shown)
                      if (showProfileIcon)
                        GestureDetector(
                          onTap: onProfileTap ?? () => Navigator.of(context).pushNamed('/settings'),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryLight,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120); // Increased height for curved design
}

class CurvedAppBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryLight, AppColors.gradientLightEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Start from top left
    path.moveTo(0, 0);
    // Line to top right
    path.lineTo(size.width, 0);
    // Line down to near bottom right
    path.lineTo(size.width, size.height - 20);
    
    // Create curved bottom
    final controlPoint1 = Offset(size.width * 0.75, size.height);
    final controlPoint2 = Offset(size.width * 0.25, size.height);
    final endPoint = Offset(0, size.height - 20);
    
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );
    
    // Close the path
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final shadowPath = Path.from(path);
    shadowPath.transform(Matrix4.translationValues(0, 2, 0).storage);
    
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashboardTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String date;

  const DashboardTopAppBar({
    super.key,
    required this.greeting,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          child: Stack(
            children: [
              // Custom curved shape with concave corners
              Positioned.fill(
                child: CustomPaint(
                  painter: CurvedAppBarPainter(),
                ),
              ),
              // Content positioned in the middle area
              Positioned(
                left: 0,
                right: 0,
                top: 20, // Move content down to center vertically
                bottom: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      // Greeting and date on the left
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Profile button on the right
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/settings'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryLight,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120); // Same height as CustomTopAppBar
}