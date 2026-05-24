import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/task_model.dart';
import '../../routes/app_routes.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';
import './widgets/add_task_sheet_widget.dart';
import './widgets/home_action_buttons_widget.dart';
import './widgets/task_card_widget.dart';
import './widgets/task_detail_sheet_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final DatabaseService _db = DatabaseService();
  List<TaskModel> _todayTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  String get _todayDateString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadTodayTasks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await _db.getTasksForDate(_todayDateString);
      if (mounted) {
        setState(() {
          _todayTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheetWidget(
        onTaskAdded: (task) async {
          await _db.insertTask(task);
          await _loadTodayTasks();
        },
      ),
    );
  }

  void _openAiChat() {
    context.push(AppRoutes.aiChatScreen);
  }

  void _openTaskDetail(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheetWidget(
        task: task,
        onDelete: () async {
          if (task.id != null) {
            await _db.deleteTask(task.id!);
          }
          if (mounted) Navigator.pop(context);
          await _loadTodayTasks();
        },
        onEdit: (updatedTask) async {
          await _db.updateTask(updatedTask);
          if (mounted) Navigator.pop(context);
          await _loadTodayTasks();
        },
        onToggleComplete: (completed) async {
          if (task.id != null) {
            await _db.markTaskCompleted(task.id!, completed);
          }
          await _loadTodayTasks();
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getDayLabel() {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[now.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadTodayTasks,
          color: AppTheme.primary,
          backgroundColor: AppTheme.surfaceDark,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getDayLabel(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'auto_awesome_rounded',
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: HomeActionButtonsWidget(
                    onAddTask: _openAddTaskSheet,
                    onAiTimetable: _openAiChat,
                  ),
                ),
              ),

              // Today's Tasks Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        "Today's Tasks",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_todayTasks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_todayTasks.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Task list or empty/loading
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => const _TaskSkeleton(),
                      childCount: 4,
                    ),
                  ),
                )
              else if (_todayTasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: EmptyStateWidget(
                      iconName: 'task_alt_rounded',
                      title: 'No tasks yet',
                      subtitle:
                          'Create one to get started, or let AI generate your perfect timetable.',
                      ctaLabel: 'Add Manual Task',
                      onCta: _openAddTaskSheet,
                    ),
                  ),
                )
              else if (isTablet)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.8,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => TaskCardWidget(
                        task: _todayTasks[i],
                        onTap: () => _openTaskDetail(_todayTasks[i]),
                      ),
                      childCount: _todayTasks.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCardWidget(
                          task: _todayTasks[i],
                          onTap: () => _openTaskDetail(_todayTasks[i]),
                        ),
                      ),
                      childCount: _todayTasks.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskSkeleton extends StatelessWidget {
  const _TaskSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
    );
  }
}
