import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasko/auth/auth_provider.dart';
import 'package:tasko/features/auth/sign_in_screen.dart';
import 'package:tasko/features/home/home_shell.dart';
import 'package:tasko/features/labels/labels_screen.dart';
import 'package:tasko/features/settings/settings_screen.dart';
import 'package:tasko/features/tasks/task_detail_screen.dart';
import 'package:tasko/features/update/update_check_host.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final signedIn = auth.isSignedIn;
      final onSignIn = state.matchedLocation == '/sign-in';
      if (!signedIn && !onSignIn) return '/sign-in';
      if (signedIn && onSignIn) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return UpdateCheckHost(child: child);
        },
        routes: [
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeShell(),
          ),
          GoRoute(
            path: '/labels',
            builder: (context, state) => const LabelsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/task/:listId/:taskId',
            builder: (context, state) {
              return TaskDetailScreen(
                listId: state.pathParameters['listId']!,
                taskId: state.pathParameters['taskId'],
              );
            },
          ),
          GoRoute(
            path: '/task/new',
            builder: (context, state) {
              final listId = state.uri.queryParameters['listId'];
              return TaskDetailScreen(listId: listId, taskId: null);
            },
          ),
        ],
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
