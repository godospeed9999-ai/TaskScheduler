import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadgeWidget({super.key, required this.label, this.color});

  static Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return AppTheme.categoryStudy;
      case 'work':
        return AppTheme.categoryWork;
      case 'health':
        return AppTheme.categoryHealth;
      case 'personal':
        return AppTheme.categoryPersonal;
      default:
        return AppTheme.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _colorForCategory(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withAlpha(77), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
