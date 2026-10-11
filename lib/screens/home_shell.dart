import 'package:flutter/material.dart';
import '../widgets/notch_nav_bar.dart';
import 'favorites_screen.dart';
import 'main_screen.dart';
import 'product_screen.dart';
import 'settings_screen.dart';

/// Hosts the four top-level tabs in a swipeable [PageView] with the notch
/// bottom bar following the page position.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _pages = PageController();
  final _position = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _pages.addListener(() => _position.value = _pages.page ?? 0);
  }

  @override
  void dispose() {
    _pages.dispose();
    _position.dispose();
    super.dispose();
  }

  void _select(int i) => _pages.animateToPage(
    i,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pages,
        children: const [
          _KeepAlive(child: FavoritesScreen()),
          _KeepAlive(child: MainScreen()),
          _KeepAlive(child: ProductScreen()),
          _KeepAlive(child: SettingsScreen()),
        ],
      ),
      bottomNavigationBar: NotchNavBar(
        position: _position,
        onSelected: _select,
        items: const [
          NotchNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          NotchNavItem(
            icon: Icons.restaurant_menu_outlined,
            activeIcon: Icons.restaurant_menu_rounded,
          ),
          NotchNavItem(
            icon: Icons.eco_outlined,
            activeIcon: Icons.eco_rounded,
          ),
          NotchNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ],
      ),
    );
  }
}

/// Keeps a tab's state alive while it is scrolled off-screen.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
