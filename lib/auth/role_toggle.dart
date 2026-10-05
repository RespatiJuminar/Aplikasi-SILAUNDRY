import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';

/// Pilihan masuk sebagai Customer atau Admin (di atas form login/register).
class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key, required this.role, required this.onChanged});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(UserRole value, String label, IconData icon) {
      final selected = role == value;
      return Expanded(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : const Color(0xFF808080),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: selected ? Colors.white : const Color(0xFF808080),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          option(UserRole.customer, 'Customer', Icons.person_outline),
          option(UserRole.admin, 'Admin', Icons.admin_panel_settings_outlined),
        ],
      ),
    );
  }
}
