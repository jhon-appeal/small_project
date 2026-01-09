import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:small_project/features/auth/views/login_view.dart';
import 'package:small_project/features/auth/views/signup_view.dart';
import 'package:small_project/features/dashboard/views/dashboard_view.dart';
import 'package:small_project/features/milestones/views/milestone_detail_view.dart';
import 'package:small_project/features/projects/viewmodels/projects_viewmodel.dart';
import 'package:small_project/features/projects/views/project_detail_view.dart';
import 'package:small_project/features/projects/views/projects_list_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoginRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ProjectsViewModel(),
          child: const ProjectsListView(),
        ),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailView(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/milestones/:projectId/:milestoneId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final milestoneId = state.pathParameters['milestoneId']!;
          return MilestoneDetailView(
            projectId: projectId,
            milestoneId: milestoneId,
          );
        },
      ),
    ],
  );
}

