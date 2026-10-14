import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

// ---------------------------------------------------------------------------
// 1. Model
// ---------------------------------------------------------------------------
class OrderSummary {
  const OrderSummary({
    required this.requested,
    required this.accepted,
    required this.inProgress,
    required this.upcoming,
  });

  final int requested; // new requests waiting for the seller to accept/reject
  final int accepted; // accepted, not started yet
  final int inProgress; // being prepared / out for delivery
  final int upcoming; // scheduled for a later date/time

  static const empty = OrderSummary(requested: 0, accepted: 0, inProgress: 0, upcoming: 0);

  // Adjust the keys to match your backend response.
  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
    requested: (json['requested'] ?? 0) as int,
    accepted: (json['accepted'] ?? 0) as int,
    inProgress: (json['inProgress'] ?? 0) as int,
    upcoming: (json['upcoming'] ?? 0) as int,
  );
}

// ---------------------------------------------------------------------------
// 2. Provider (wire to your repository / ApiClient)
// ---------------------------------------------------------------------------
final orderSummaryProvider = FutureProvider.autoDispose<OrderSummary>((ref) async {
  // TODO: replace with your real call, for example:
  // final json = await ref.read(apiClientProvider).get('/seller/orders/summary');
  // return OrderSummary.fromJson(json);
  return OrderSummary.empty;
});

// ---------------------------------------------------------------------------
// 3. Section widget: drop it into the dashboard ListView
// ---------------------------------------------------------------------------
class SellerOrdersSummarySection extends ConsumerWidget {
  const SellerOrdersSummarySection({super.key, this.onTapStatus});

  /// Called with 'requested' | 'accepted' | 'inProgress' | 'upcoming'
  /// so you can open the orders list filtered by that status.
  final void Function(String status)? onTapStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(orderSummaryProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedReceipt, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Orders', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Row(
                children: [
                  const Expanded(child: Text('Could not load orders')),
                  TextButton(
                    onPressed: () => ref.invalidate(orderSummaryProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (s) => Column(
                children: [
                  // Requested is the one that needs action, so it gets its own row.
                  _RequestedBanner(count: s.requested, onTap: () => onTapStatus?.call('requested')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CountTile(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        label: 'Accepted',
                        count: s.accepted,
                        onTap: () => onTapStatus?.call('accepted'),
                      ),
                      _CountTile(
                        icon: HugeIcons.strokeRoundedFire,
                        label: 'In progress',
                        count: s.inProgress,
                        onTap: () => onTapStatus?.call('inProgress'),
                      ),
                      _CountTile(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        label: 'Upcoming',
                        count: s.upcoming,
                        onTap: () => onTapStatus?.call('upcoming'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestedBanner extends StatelessWidget {
  const _RequestedBanner({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasRequests = count > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasRequests ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: hasRequests ? HugeIcons.strokeRoundedNotification01 : HugeIcons.strokeRoundedInbox,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasRequests
                    ? '$count new order ${count == 1 ? 'request' : 'requests'}'
                    : 'No new order requests',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (hasRequests) const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.icon, required this.label, required this.count, this.onTap});

  final List<List<dynamic>> icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              HugeIcon(icon: icon, size: 22),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
