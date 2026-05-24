import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class HomeActionButtonsWidget extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAiTimetable;

  const HomeActionButtonsWidget({
    super.key,
    required this.onAddTask,
    required this.onAiTimetable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Manual Task
        _ActionButton(
          label: 'Add Manual Task',
          subtitle: 'Create a task with custom time & category',
          iconName: 'add_task_rounded',
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C3A), Color(0xFF252550)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: AppTheme.secondary,
          onTap: onAddTask,
        ),
        const SizedBox(height: 12),
        // Generate AI Timetable
        _ActionButton(
          label: 'Generate AI Timetable',
          subtitle: 'Chat with AI to build your perfect schedule',
          iconName: 'auto_awesome_rounded',
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withAlpha(77),
              AppTheme.primaryContainer.withAlpha(128),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: AppTheme.primaryLight,
          onTap: onAiTimetable,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final String iconName;
  final Gradient gradient;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.subtitle,
    required this.iconName,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.accentColor.withAlpha(51),
                  width: 1,
                ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(51),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.accentColor.withAlpha(64),
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.iconName,
                        color: widget.accentColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'arrow_forward_ios_rounded',
                    color: widget.accentColor.withAlpha(179),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
