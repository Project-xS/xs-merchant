import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant/providers/auth_provider.dart';
import 'package:merchant/l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String canteenName;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.canteenName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: const Color(0xFFE5E7EB), // gray-200
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          // Branding Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB), // blue-600
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.coffee, // Placeholder icon
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Canteen Manager",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827), // gray-900
                      ),
                    ),
                    Text(
                      canteenName,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  label: "Dashboard",
                  index: 0,
                  localizations: localizations,
                  onTap: onItemSelected,
                  isSelected: selectedIndex == 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.fastfood, // Placeholder icon
                  label: "Item Management",
                  index: 1,
                  localizations: localizations,
                  onTap: onItemSelected,
                  isSelected: selectedIndex == 1,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.search, // Placeholder icon
                  label: "Order Lookup",
                  index: 2,
                  localizations: localizations,
                  onTap: onItemSelected,
                  isSelected: selectedIndex == 2,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_today, // Placeholder icon
                  label: "Pre-Orders",
                  index: 3,
                  localizations: localizations,
                  onTap: onItemSelected,
                  isSelected: selectedIndex == 3,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics, // Placeholder icon
                  label: "Analytics",
                  index: 4,
                  localizations: localizations,
                  onTap: onItemSelected,
                  isSelected: selectedIndex == 4,
                ),
              ],
            ),
          ),
          // Footer (Sign Out)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  authProvider.logout();
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  alignment: Alignment.centerLeft,
                ),
                icon: Icon(
                  Icons.logout,
                  size: 20,
                  color: const Color(0xFF6B7280), // gray-500
                ),
                label: Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B7280), // gray-500
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required AppLocalizations localizations,
    required Function(int) onTap,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        hoverColor: const Color(0xFFF8FAFC), // gray-50
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent, // blue-50
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFFBFDBFE)) // blue-200
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF111827), // blue-600 / gray-900
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF111827), // blue-600 / gray-900
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
