import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCardWidget({super.key, required this.task, required this.onTap});

  Color get _categoryAccent {
    switch (task.category.toLowerCase()) {
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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: _categoryAccent.withAlpha(13),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _categoryAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                // Time column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.startTime,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      task.endTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Title + category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      StatusBadgeWidget(label: task.category),
                    ],
                  ),
                ),
                // Complete indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppTheme.success.withAlpha(38)
                        : AppTheme.glassSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppTheme.success.withAlpha(102)
                          : AppTheme.glassBorder,
                    ),
                  ),
                  child: task.isCompleted
                      ? Center(
                          child: CustomIconWidget(
                            iconName: 'check_rounded',
                            color: AppTheme.success,
                            size: 16,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
