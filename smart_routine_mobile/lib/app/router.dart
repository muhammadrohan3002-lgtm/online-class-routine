import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/attendance/presentation/attendance_screen.dart';
import '../features/calendar/presentation/add_edit_exam_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/courses/presentation/add_edit_course_screen.dart';
import '../features/courses/presentation/courses_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/server_config_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/routine/presentation/add_edit_routine_screen.dart';
import '../features/routine/presentation/routine_screen.dart';
import '../features/study_planner/presentation/study_planner_screen.dart';
import '../features/study_planner/presentation/study_timer_screen.dart';
import '../features/tasks/presentation/add_edit_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;

      final isPublicRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password' ||
          loc == '/reset-password' ||
          loc == '/settings/server';

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && (loc == '/login' || loc == '/register')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final code = state.uri.queryParameters['code'];
          return ResetPasswordScreen(initialEmail: email, initialCode: code);
        },
      ),

      // Main Shell with Bottom Navigation Bar (5 tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Routine',
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_box_outlined),
                  selectedIcon: Icon(Icons.check_box_rounded),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_outlined),
                  selectedIcon: Icon(Icons.event_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
        branches: [
          // Branch 1: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 2: Routine
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/routine',
                builder: (context, state) => const RoutineScreen(),
              ),
            ],
          ),
          // Branch 3: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
            ],
          ),
          // Branch 4: Calendar / Exams
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Branch 5: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Courses routes
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/courses/add',
        builder: (context, state) => const AddEditCourseScreen(),
      ),
      GoRoute(
        path: '/courses/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditCourseScreen(courseId: id);
        },
      ),

      // Routine Add/Edit routes
      GoRoute(
        path: '/routine/add',
        builder: (context, state) {
          final dayStr = state.uri.queryParameters['day'];
          final day = dayStr != null ? int.tryParse(dayStr) : null;
          return AddEditRoutineScreen(initialDay: day);
        },
      ),
      GoRoute(
        path: '/routine/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditRoutineScreen(routineId: id);
        },
      ),

      // Tasks Add/Edit routes
      GoRoute(
        path: '/tasks/add',
        builder: (context, state) => const AddEditTaskScreen(),
      ),
      GoRoute(
        path: '/tasks/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditTaskScreen(taskId: id);
        },
      ),

      // Calendar Add/Edit routes
      GoRoute(
        path: '/calendar/add',
        builder: (context, state) => const AddEditExamScreen(),
      ),
      GoRoute(
        path: '/calendar/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditExamScreen(examId: id);
        },
      ),

      // Attendance Route
      GoRoute(
        path: '/attendance',
        builder: (context, state) {
          final autoRecord = state.uri.queryParameters['record'] == 'true';
          final courseId = state.uri.queryParameters['courseId'];
          final courseName = state.uri.queryParameters['courseName'];
          return AttendanceScreen(
            autoOpenRecord: autoRecord,
            initialCourseId: courseId,
            initialCourseName: courseName,
          );
        },
      ),

      // Study Planner & Focus Timer Routes
      GoRoute(
        path: '/study-planner',
        builder: (context, state) => const StudyPlannerScreen(),
      ),
      GoRoute(
        path: '/study-planner/timer',
        builder: (context, state) => const StudyTimerScreen(),
      ),

      // Settings & Profile routes
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/server',
        builder: (context, state) => const ServerConfigScreen(),
      ),
    ],
  );
});
