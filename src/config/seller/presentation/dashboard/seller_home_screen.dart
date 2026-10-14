import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/presentation/dashboard/widgets/order_summary_card_widget.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';

/// The Home tab of the seller dashboard. No `Scaffold`/`AppBar` here — this
/// is embedded under `SellerDashboardScreen`'s own AppBar via `IndexedStack`.
class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key, this.onViewListings, this.onViewOrders, this.onViewReviews});

  /// Switches the dashboard to the corresponding tab. Left null (no-op) if
  /// this screen is ever used outside the dashboard's tab bar.
  final VoidCallback? onViewListings;
  final VoidCallback? onViewOrders;
  final VoidCallback? onViewReviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(sellerProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(sellerProvider),
      child: sellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('Could not load seller details')),
          ],
        ),
        data: (seller) {
          if (seller == null) return const _NotASeller();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(seller: seller),
              const SizedBox(height: 12),
              _StatusBanners(seller: seller),
              _AvailabilityCard(seller: seller),
              const SizedBox(height: 12),
              SellerOrdersSummarySection(onTapStatus: (_) => onViewOrders?.call()),
              const SizedBox(height: 12),
              _StatsRow(seller: seller),
              const SizedBox(height: 12),
              _ListingsCard(seller: seller, onViewListings: onViewListings),
              const SizedBox(height: 12),
              _PerformanceCard(seller: seller),
              const SizedBox(height: 12),
              _ReviewsPreviewCard(seller: seller, onViewReviews: onViewReviews),
            ],
          );
        },
      ),
    );
  }
}

String _cap(String s) {
  final t = s.replaceAll('_', ' ').toLowerCase();
  return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
}

bool _isApproved(SellerProfileEntity s) => s.approvalStatus.toUpperCase() == 'APPROVED';

class _NotASeller extends StatelessWidget {
  const _NotASeller();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedStore01),
            title: const Text('You are not a seller yet'),
            subtitle: const Text('Register to start selling'),
            trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: () => context.push('/modules/seller/onboarding', extra: false),
          ),
        ),
      ],
    );
  }
}

/// Icon + colors for a seller approval status, pulled from the current
/// ColorScheme so it follows light/dark theme automatically.
class _StatusStyle {
  const _StatusStyle({required this.icon, required this.container, required this.onContainer});

  final List<List<dynamic>> icon;
  final Color container;
  final Color onContainer;

  static _StatusStyle forStatus(String status, ColorScheme scheme) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return _StatusStyle(
          icon: HugeIcons.strokeRoundedStoreVerified01,
          container: scheme.primaryContainer,
          onContainer: scheme.onPrimaryContainer,
        );
      case 'PENDING':
      case 'SUBMITTED':
        return _StatusStyle(
          icon: HugeIcons.strokeRoundedHourglass,
          container: scheme.secondaryContainer,
          onContainer: scheme.onSecondaryContainer,
        );
      case 'REJECTED':
        return _StatusStyle(
          icon: HugeIcons.strokeRoundedAlertCircle,
          container: scheme.errorContainer,
          onContainer: scheme.onErrorContainer,
        );
      default: // DRAFT or unknown
        return _StatusStyle(
          icon: HugeIcons.strokeRoundedFileEdit,
          container: scheme.surfaceContainerHighest,
          onContainer: scheme.onSurfaceVariant,
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.seller});
  final SellerProfileEntity seller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (seller.businessName?.isNotEmpty ?? false)
        ? seller.businessName!
        : seller.displayName;
    final status = _StatusStyle.forStatus(seller.approvalStatus, theme.colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: status.container,
              child: HugeIcon(icon: status.icon, color: status.onContainer, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hind(
                      textStyle: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_cap(seller.sellerType), style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Chip(
              label: Text(_cap(seller.approvalStatus)),
              backgroundColor: status.container,
              side: BorderSide.none,
              labelStyle: TextStyle(color: status.onContainer, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blockers first: approval and FSSAI.
class _StatusBanners extends StatelessWidget {
  const _StatusBanners({required this.seller});
  final SellerProfileEntity seller;

  @override
  Widget build(BuildContext context) {
    final banners = <Widget>[];

    switch (seller.approvalStatus.toUpperCase()) {
      case 'DRAFT':
        banners.add(
          _Banner(
            icon: HugeIcons.strokeRoundedFileEdit,
            text: 'Your seller profile is a draft. Submit it to start selling.',
            actionLabel: 'Complete',
            onAction: () => context.push('/modules/seller/onboarding', extra: true),
          ),
        );
        break;
      case 'PENDING':
      case 'SUBMITTED':
        banners.add(
          const _Banner(icon: HugeIcons.strokeRoundedHourglass, text: 'Your profile is under review.'),
        );
        break;
      case 'REJECTED':
        banners.add(
          _Banner(
            icon: HugeIcons.strokeRoundedAlertCircle,
            text: 'Your profile was rejected. Update details and re-submit.',
            actionLabel: 'Update',
            onAction: () => context.push('/modules/seller/onboarding', extra: true),
            isError: true,
          ),
        );
        break;
    }

    if (seller.fssaiRequired && seller.fssaiStatus.toUpperCase() != 'APPROVED') {
      banners.add(
        _Banner(
          icon: HugeIcons.strokeRoundedShieldCheck,
          text: 'FSSAI verification: ${_cap(seller.fssaiStatus)}',
        ),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(children: banners);
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  final List<List<dynamic>> icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: isError ? scheme.onErrorContainer : scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isError ? scheme.onErrorContainer : scheme.onSecondaryContainer),
            ),
          ),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.seller});
  final SellerProfileEntity seller;

  @override
  Widget build(BuildContext context) {
    final available = seller.availabilityStatus.toUpperCase() == 'AVAILABLE';
    final approved = _isApproved(seller);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: SwitchListTile(
        secondary: HugeIcon(
          icon: available ? HugeIcons.strokeRoundedToggleOn : HugeIcons.strokeRoundedToggleOff,
          color: available ? scheme.primary : scheme.outline,
        ),
        title: Text(available ? 'Accepting orders' : 'Not accepting orders'),
        subtitle: Text(
          approved ? 'Changing this is coming soon' : 'Available after approval',
        ),
        value: available,
        onChanged: approved
            ? (value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Availability toggle is coming soon')),
              )
            : null,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.seller});
  final SellerProfileEntity seller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(icon: HugeIcons.strokeRoundedReceipt, label: 'Orders', value: '${seller.totalOrders}'),
        _StatCard(icon: HugeIcons.strokeRoundedPackage01, label: 'Listings', value: '${seller.totalListings}'),
        _StatCard(
          icon: HugeIcons.strokeRoundedStar,
          label: 'Rating',
          value: seller.totalReviews == 0 ? '-' : seller.averageRating.toStringAsFixed(1),
        ),
        _StatCard(icon: HugeIcons.strokeRoundedComment01, label: 'Reviews', value: '${seller.totalReviews}'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              HugeIcon(icon: icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingsCard extends StatelessWidget {
  const _ListingsCard({required this.seller, this.onViewListings});
  final SellerProfileEntity seller;
  final VoidCallback? onViewListings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = seller.totalListings == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedPackage01, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Listings', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              empty
                  ? 'Add your first item so customers can find you.'
                  : '${seller.totalListings} active listings',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onViewListings,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedPackageAdd01, size: 18),
                label: Text(empty ? 'Add new listing' : 'View listings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.seller});
  final SellerProfileEntity seller;

  String _pct(int part, int total) =>
      total == 0 ? '-' : '${(part * 100 / total).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = seller.totalOrders;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedChartLineData01, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Performance', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            _row(
              'Rejected orders',
              '${seller.rejectedOrders} (${_pct(seller.rejectedOrders, total)})',
            ),
            _row(
              'Cancelled orders',
              '${seller.cancelledOrders} (${_pct(seller.cancelledOrders, total)})',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value),
      ],
    ),
  );
}

class _ReviewsPreviewCard extends StatelessWidget {
  const _ReviewsPreviewCard({required this.seller, this.onViewReviews});
  final SellerProfileEntity seller;
  final VoidCallback? onViewReviews;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReviews = seller.totalReviews > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedStar, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasReviews ? '${seller.averageRating.toStringAsFixed(1)} average rating' : 'No reviews yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text('${seller.totalReviews} total reviews', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            TextButton(onPressed: onViewReviews, child: const Text('View all')),
          ],
        ),
      ),
    );
  }
}
