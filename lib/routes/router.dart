import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tavolo_mobile/navigation/bottom_navigation.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_bloc.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_state.dart';
import 'package:tavolo_mobile/presentation/auth/screens/login_screen.dart';
import 'package:tavolo_mobile/presentation/auth/screens/register_screen.dart';
import 'package:tavolo_mobile/presentation/headquarters/screens/search-headquarters_screen.dart';

import '../presentation/home/screens/home_screen.dart';
import '../presentation/menu/screens/menu_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state is Authenticated;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';

      // Si no está autenticado y no está en una ruta de autenticación, redirigir a login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Si está autenticado y está en una ruta de autenticación, redirigir a home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Rutas con navegación inferior
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavigation(
            currentRoute: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/headquarters',
            builder: (context, state) => const SearchHeadquartersScreen()
          ),
          GoRoute(
            path: '/menu',
            builder: (context, state) => const MenuScreen(),
          ),
        ],
      ),
    ],
  );
}

// Clase auxiliar para convertir el stream del BLoC a un Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}