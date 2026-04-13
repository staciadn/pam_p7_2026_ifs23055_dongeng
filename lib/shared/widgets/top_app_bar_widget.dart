import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_constants.dart';
import '../../core/theme/theme_notifier.dart';

class TopAppBarMenuItem {
  const TopAppBarMenuItem({
    required this.text, required this.icon,
    this.route, this.onTap, this.isDestructive = false,
  });
  final String text;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
  final bool isDestructive;
}

class TopAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const TopAppBarWidget({
    super.key, required this.title,
    this.showBackButton = false, this.withSearch = false,
    this.searchQuery = '', this.onSearchQueryChange,
    this.menuItems = const [],
  });

  final String title;
  final bool showBackButton;
  final bool withSearch;
  final String searchQuery;
  final ValueChanged<String>? onSearchQueryChange;
  final List<TopAppBarMenuItem> menuItems;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<TopAppBarWidget> createState() => _TopAppBarWidgetState();
}

class _TopAppBarWidgetState extends State<TopAppBarWidget> {
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeNotifier = ThemeProvider.of(context);
    final isDark = themeNotifier.isDark;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 4,
      leading: widget.showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (context.canPop()) context.pop();
          else context.go(RouteConstants.home);
        },
      )
          : null,
      title: _isSearchActive
          ? TextField(
        controller: _searchController, autofocus: true,
        decoration: InputDecoration(hintText: 'Cari...', border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant)),
        onChanged: widget.onSearchQueryChange,
      )
          : Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            key: ValueKey(isDark),
            icon: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: themeNotifier.toggle,
          ),
        ),
        if (widget.withSearch)
          _isSearchActive
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _isSearchActive = false);
              _searchController.clear();
              widget.onSearchQueryChange?.call('');
            },
          )
              : IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearchActive = true),
          ),
        if (widget.menuItems.isNotEmpty)
          PopupMenuButton<TopAppBarMenuItem>(
            icon: const Icon(Icons.more_vert),
            color: colorScheme.primaryContainer,
            itemBuilder: (context) => widget.menuItems.map((item) =>
                PopupMenuItem<TopAppBarMenuItem>(
                  value: item,
                  child: Row(children: [
                    Icon(item.icon, size: 20,
                        color: item.isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(item.text, style: TextStyle(
                        color: item.isDestructive ? colorScheme.error : colorScheme.onSurface,
                        fontWeight: item.isDestructive ? FontWeight.bold : FontWeight.normal)),
                  ]),
                )
            ).toList(),
            onSelected: (item) {
              if (item.route != null) context.go(item.route!);
              item.onTap?.call();
            },
          ),
      ],
    );
  }
}