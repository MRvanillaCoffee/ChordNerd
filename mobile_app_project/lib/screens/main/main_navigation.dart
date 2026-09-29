import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../search/search_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';

/// The main tab shell shown once a user is signed in — holds
/// Dashboard/Search/Library/Profile and keeps each tab's state alive
/// via IndexedStack (so scroll position etc. isn't lost when switching).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
