import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// Shared "nothing here yet" placeholder for the Listings/Orders/Reviews
/// tabs, used while those sections have no backend data to show.
class SellerEmptyState extends StatelessWidget {
  const SellerEmptyState({super.key, required this.icon, required this.title, this.message});

  final List<List<dynamic>> icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          HugeIcon(icon: icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.hind(
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared error row with a retry action, matching the CloudOff/Refresh01
/// pattern already used on the profile screen.
class SellerErrorRow extends StatelessWidget {
  const SellerErrorRow({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedCloudOff, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton.icon(
            onPressed: onRetry,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh01, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
