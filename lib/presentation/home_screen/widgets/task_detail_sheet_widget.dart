import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/task_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/status_badge_widget.dart';
import './add_task_sheet_widget.dart';
import './focus_mode_widget.dart';

class TaskDetailSheetWidget extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onDelete;
  final Future<void> Function(TaskModel task) onEdit;
  final Future<void> Function(bool completed) onToggleComplete;

  const TaskDetailSheetWidget({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleComplete,
  });

  @override
  State<TaskDetailSheetWidget> createState() => _TaskDetailSheetWidgetState();
}

class _TaskDetailSheetWidgetState extends State<TaskDetailSheetWidget> {
  bool _focusModeEnabled = false;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Task',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This task will be permanently deleted.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openEdit() {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) return;
      // Caller handles reopening edit sheet
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheetWidget(
        existingTask: widget.task,
        onTaskAdded: widget.onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_focusModeEnabled) {
      return FocusModeWidget(
        task: widget.task,
        onExit: () {
          setState(() => _focusModeEnabled = false);
        },
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withAlpha(242),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StatusBadgeWidget(label: widget.task.category),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.task.startTime} – ${widget.task.endTime}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.task.description != null &&
                  widget.task.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  widget.task.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Mark complete toggle
              GestureDetector(
                onTap: () async {
                  setState(() => _isCompleted = !_isCompleted);
                  await widget.onToggleComplete(_isCompleted);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? AppTheme.success.withAlpha(26)
                        : AppTheme.glassSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCompleted
                          ? AppTheme.success.withAlpha(77)
                          : AppTheme.glassBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: _isCompleted
                            ? 'check_circle_rounded'
                            : 'radio_button_unchecked_rounded',
                        color: _isCompleted
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isCompleted ? 'Completed' : 'Mark as Complete',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _isCompleted
                              ? AppTheme.success
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Focus mode toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'center_focus_strong_rounded',
                      color: AppTheme.primaryLight,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Enable Focus Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _focusModeEnabled,
                      onChanged: (v) => setState(() => _focusModeEnabled = v),
                      activeThumbColor: AppTheme.primaryLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Edit + Delete
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openEdit,
                      icon: CustomIconWidget(
                        iconName: 'edit_rounded',
                        color: AppTheme.secondary,
                        size: 18,
                      ),
                      label: const Text('Edit Task'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        side: BorderSide(
                          color: AppTheme.secondary.withAlpha(77),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteConfirm,
                      icon: CustomIconWidget(
                        iconName: 'delete_rounded',
                        color: AppTheme.error,
                        size: 18,
                      ),
                      label: const Text('Remove Task'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error.withAlpha(77)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
