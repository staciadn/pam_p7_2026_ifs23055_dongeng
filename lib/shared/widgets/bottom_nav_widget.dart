import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_constants.dart';

class _NavItem {
  const _NavItem({required this.label, required this.route,
    required this.icon, required this.activeIcon});
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key, required this.child});
  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home', route: RouteConstants.home,
        icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(label: 'Plants', route: RouteConstants.plants,
        icon: Icons.eco_outlined, activeIcon: Icons.eco),
    _NavItem(label: 'Dongeng', route: RouteConstants.dongeng,
        icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
    _NavItem(label: 'Profil', route: RouteConstants.profile,
        icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  int _getSelectedIndex(String location) {
    if (location == RouteConstants.home) return 0;
    if (location.startsWith(RouteConstants.plants)) return 1;
    if (location.startsWith(RouteConstants.dongeng)) return 2;
    if (location.startsWith(RouteConstants.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20, offset: const Offset(0, -6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ColoredBox(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Colors.transparent,
              selectedIndex: _getSelectedIndex(currentLocation),
              onDestinationSelected: (index) => context.go(_items[index].route),
              destinations: _items.map((item) {
                final isSelected = item.route == RouteConstants.home
                    ? currentLocation == item.route
                    : currentLocation.startsWith(item.route);
                return NavigationDestination(
                  icon: _NavIcon(item: item, isSelected: isSelected),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.isSelected});
  final _NavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48, height: 48,
      decoration: isSelected
          ? BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      )
          : null,
      child: Icon(isSelected ? item.activeIcon : item.icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
    );
  }
}