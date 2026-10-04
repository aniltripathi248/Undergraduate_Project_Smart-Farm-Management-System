import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SfmsLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const SfmsLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreenLight, AppTheme.primaryGreenDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.agriculture_rounded,
              size: size * 0.58,
              color: Colors.white,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          Text(
            'Smart Farm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Management System (SFMS)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppTheme.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
