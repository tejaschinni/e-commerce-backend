import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle = 'Coming soon',
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.hind(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
