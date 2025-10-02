import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_service.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/campaigns/presentation/campaign_detail_screen.dart';
import '../features/campaigns/presentation/campaign_feed_screen.dart';
import '../features/landing/presentation/landing_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return ref.watch(appRouterProvider);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/sign-in';
      final isLandingRoute = state.matchedLocation == '/';

      // If authenticated and on auth/landing screen, redirect to campaigns
      if (isAuthenticated && (isAuthRoute || isLandingRoute)) {
        return '/campaigns';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: LandingScreen.routeName,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LandingScreen(),
        ),
      ),
      GoRoute(
        path: '/sign-in',
        name: SignInScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/campaigns',
        name: CampaignFeedScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CampaignFeedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0.03, 0), end: Offset.zero);
            final offsetAnimation = animation.drive(tween);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: CampaignDetailScreen.routeName,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomTransitionPage(
                key: state.pageKey,
                child: CampaignDetailScreen(campaignId: id),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: ProfileScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => const LandingScreen(),
    observers: [
      _AequusRouteObserver(),
    ],
  );
});

class _AequusRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('Route pushed: ${route.settings.name ?? route.settings}');
  }
}
