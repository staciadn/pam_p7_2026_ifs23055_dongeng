import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/plants/plants_screen.dart';
import '../../features/plants/plants_add_screen.dart';
import '../../features/plants/plants_detail_screen.dart';
import '../../features/plants/plants_edit_screen.dart';
import '../../features/dongeng/dongeng_screen.dart';
import '../../features/dongeng/dongeng_add_screen.dart';
import '../../features/dongeng/dongeng_detail_screen.dart';
import '../../features/dongeng/dongeng_edit_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../router/route_constants.dart';
import '../../shared/widgets/bottom_nav_widget.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: RouteConstants.home,
            builder: (context, state) => const HomeScreen()),
        GoRoute(path: RouteConstants.plants,
            builder: (context, state) => const PlantsScreen()),
        GoRoute(path: RouteConstants.dongeng,
            builder: (context, state) => const DongengScreen()),
        GoRoute(path: RouteConstants.profile,
            builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/plants/add',
        builder: (context, state) => const PlantsAddScreen()),
    GoRoute(path: '/plants/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlantsDetailScreen(plantId: id);
        }),
    GoRoute(path: '/plants/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlantsEditScreen(plantId: id);
        }),
    GoRoute(path: '/dongeng/add',
        builder: (context, state) => const DongengAddScreen()),
    GoRoute(path: '/dongeng/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DongengDetailScreen(dongengId: id);
        }),
    GoRoute(path: '/dongeng/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DongengEditScreen(dongengId: id);
        }),
  ],
);

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavWidget(child: child),
    );
  }
}