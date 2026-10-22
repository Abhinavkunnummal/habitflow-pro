import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/celebration/screens/celebration_screen.dart';
import '../../features/dashboard/screens/today_screen.dart';
import '../../features/goals/screens/create_goal_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/habit_details/screens/habit_details_screen.dart';
import '../../features/habit_form/screens/add_habit_screen.dart';
import '../../features/habit_form/screens/edit_habit_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reminders/screens/reminders_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/timer/screens/focus_timer_screen.dart';
import '../../features/weekly_review/screens/weekly_review_screen.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Non-Shell Top-Level Routes
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/habit/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddHabitScreen(),
    ),
    GoRoute(
      path: '/habit/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return HabitDetailsScreen(habitId: id);
      },
    ),
    GoRoute(
      path: '/habit/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EditHabitScreen(habitId: id);
      },
    ),
    GoRoute(
      path: '/timer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FocusTimerScreen(),
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/celebration',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CelebrationScreen(),
    ),
    GoRoute(
      path: '/goals/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateGoalScreen(),
    ),
    GoRoute(
      path: '/journal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/weekly-review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WeeklyReviewScreen(),
    ),
    GoRoute(
      path: '/reminders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RemindersScreen(),
    ),

    // Stateful Navigation Shell for 5 Tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Today
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        // Tab 2: Insights
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const InsightsScreen(),
            ),
          ],
        ),
        // Tab 3: Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // Tab 4: Goals
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsScreen(),
            ),
          ],
        ),
        // Tab 5: Profile
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
  ],
);
