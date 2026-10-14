import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerNavItem {
  const SellerNavItem({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const sellerNavItems = [
  SellerNavItem(label: 'Home', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard),
  SellerNavItem(label: 'Listings', icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt),
  SellerNavItem(
    label: 'Orders',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  SellerNavItem(label: 'Reviews', icon: Icons.reviews_outlined, selectedIcon: Icons.reviews),
  SellerNavItem(label: 'Profile', icon: Icons.storefront_outlined, selectedIcon: Icons.storefront),
];

class SellerBottomNavBar extends StatelessWidget {
  const SellerBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final item in sellerNavItems)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}
