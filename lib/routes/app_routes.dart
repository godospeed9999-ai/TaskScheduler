import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/ai_chat_screen/ai_chat_screen.dart';
import '../presentation/block_apps_screen/block_apps_screen.dart';
import '../presentation/study_screen/study_screen.dart';
import '../presentation/workout_screen/workout_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String studyScreen = '/study-screen';
  static const String workoutScreen = '/workout-screen';
  static const String blockAppsScreen = '/block-apps-screen';
  static const String aiChatScreen = '/ai-chat-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    // Splash / redirect to shell
    GoRoute(path: AppRoutes.initial, redirect: (_, __) => AppRoutes.homeScreen),
    // Main shell with persistent BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homeScreen,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 1: Study
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.studyScreen,
              builder: (context, state) => const StudyScreen(),
            ),
          ],
        ),
        // Branch 2: Workout
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.workoutScreen,
              builder: (context, state) => const WorkoutScreen(),
            ),
          ],
        ),
        // Branch 3: Block Apps
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.blockAppsScreen,
              builder: (context, state) => const BlockAppsScreen(),
            ),
          ],
        ),
      ],
    ),
    // AI Chat — opens via Navigator.push (context.push)
    GoRoute(
      path: AppRoutes.aiChatScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AiChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
  ],
);
