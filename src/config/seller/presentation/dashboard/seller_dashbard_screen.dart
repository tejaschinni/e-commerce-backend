import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:society_seva/features/auth/presentation/providers/auth_provider.dart';
import 'package:society_seva/features/location/presentation/widgets/location_header_button.dart';
import 'package:society_seva/features/profile/presentation/screens/profile_screen.dart';
import 'package:society_seva/features/seller/presentation/dashboard/seller_home_screen.dart';
import 'package:society_seva/features/seller/presentation/dashboard/seller_listings_screen.dart';
import 'package:society_seva/features/seller/presentation/dashboard/seller_orders_screen.dart';
import 'package:society_seva/features/seller/presentation/dashboard/seller_reviews_screen.dart';

import 'widgets/seller_bottom_nav_bar.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  int _index = 0;

  // Not `const`: Home needs callbacks to switch tabs. IndexedStack still
  // preserves each tab's state across rebuilds since the widget types and
  // positions stay the same.
  List<Widget> get _tabs => [
    SellerHomeScreen(
      onViewListings: () => setState(() => _index = 1),
      onViewOrders: () => setState(() => _index = 2),
      onViewReviews: () => setState(() => _index = 3),
    ),
    const SellerListingsScreen(),
    const SellerOrdersScreen(),
    const SellerReviewsScreen(),
    const ProfileScreen(),
  ];
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log out?', style: GoogleFonts.hind()),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.hind()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.hind()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: GoogleFonts.hind()),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;
    final failureMessage = await ref.read(authControllerProvider.notifier).logout();
    if (failureMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signed out locally, but server logout failed: $failureMessage',
            style: GoogleFonts.hind(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: LocationHeaderButton(compact: true))],
        ),
        actions: [
          // IconButton(
          //   onPressed: () => context.push('/profile'),
          //   icon: const HugeIcon(icon: HugeIcons.strokeRoundedUser),
          //   tooltip: 'Profile',
          // ),
          IconButton(
            onPressed: _logout,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout02),
            tooltip: 'Logout',
          ),
        ],
      ),
      // IndexedStack keeps each tab's state when switching tabs.
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: SellerBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
