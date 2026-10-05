import 'package:flutter/material.dart';
import 'account_settings_page.dart';
import 'customers_page.dart';
import 'dashboard_page.dart';
import 'orders_page.dart';
import 'service_list_page.dart';
import '../theme.dart';
import 'dialogs.dart';

enum NavItem { dashboard, users, orders, services, account }

/// Pindah halaman tanpa animasi, supaya terasa seperti aplikasi desktop.
void replacePage(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

Widget _pageFor(NavItem item) {
  switch (item) {
    case NavItem.dashboard:
      return const DashboardPage();
    case NavItem.users:
      return const CustomersPage();
    case NavItem.orders:
      return const OrdersPage();
    case NavItem.services:
      return const ServiceListPage();
    case NavItem.account:
      return const AccountSettingsPage();
  }
}

/// Sidebar kiri: logo, menu utama, akun, dan logout.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key, this.current});

  final NavItem? current;

  void _go(BuildContext context, NavItem item) {
    if (item == current) return;
    replacePage(context, _pageFor(item));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Image.asset('assets/images/logo.png', width: 68),
          const Spacer(),
          _NavButton(
            icon: Icons.dashboard_rounded,
            tooltip: 'Dashboard',
            selected: current == NavItem.dashboard,
            onTap: () => _go(context, NavItem.dashboard),
          ),
          _NavButton(
            icon: Icons.person,
            tooltip: 'Customers',
            selected: current == NavItem.users,
            onTap: () => _go(context, NavItem.users),
          ),
          _NavButton(
            icon: Icons.shopping_cart_outlined,
            tooltip: 'Orders',
            selected: current == NavItem.orders,
            onTap: () => _go(context, NavItem.orders),
          ),
          _NavButton(
            icon: Icons.settings,
            tooltip: 'Service List',
            selected: current == NavItem.services,
            onTap: () => _go(context, NavItem.services),
          ),
          const Spacer(flex: 2),
          _NavButton(
            icon: Icons.account_circle_outlined,
            tooltip: 'Account Settings',
            selected: current == NavItem.account,
            onTap: () => _go(context, NavItem.account),
          ),
          _NavButton(
            icon: Icons.logout,
            tooltip: 'Log out',
            selected: false,
            onTap: () => showLogoutDialog(context),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(90),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 26,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kerangka halaman dashboard: sidebar + judul halaman + isi.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.current,
    required this.child,
  });

  final String title;
  final NavItem? current;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(current: current),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 62,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 22),
                  alignment: Alignment.centerLeft,
                  color: AppColors.sidebar,
                  child: Text(title, style: AppText.pageTitle),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
