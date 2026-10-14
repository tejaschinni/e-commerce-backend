import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:society_seva/features/seller/presentation/dashboard/widgets/order_summary_card_widget.dart';
import 'package:society_seva/features/seller/presentation/dashboard/widgets/seller_empty_state.dart';

// ---------------------------------------------------------------------------
// Model — shaped for once a "my orders" endpoint exists.
// ---------------------------------------------------------------------------
class SellerOrderSummaryItem {
  const SellerOrderSummaryItem({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalAmount,
  });

  final String id;
  final String customerName;
  final String status;
  final double totalAmount;
}

// ---------------------------------------------------------------------------
// Provider — TODO: replace with the real "my orders" API call once one
// exists. Until then this resolves to an empty list; the counts above (from
// orderSummaryProvider) are already wired the same way and ready to swap in.
// ---------------------------------------------------------------------------
final sellerOrdersListProvider = FutureProvider.autoDispose<List<SellerOrderSummaryItem>>((
  ref,
) async {
  return const [];
});

class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orderSummaryProvider);
        ref.invalidate(sellerOrdersListProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Orders',
            style: GoogleFonts.hind(
              textStyle: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          const SellerOrdersSummarySection(),
          const SizedBox(height: 20),
          Text('Recent orders', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ordersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SellerErrorRow(
              message: 'Could not load orders',
              onRetry: () => ref.invalidate(sellerOrdersListProvider),
            ),
            data: (orders) => orders.isEmpty
                ? const SellerEmptyState(
                    icon: HugeIcons.strokeRoundedReceipt,
                    title: 'No orders yet',
                    message: 'Orders from customers will show up here.',
                  )
                : Column(children: [for (final order in orders) _OrderTile(order: order)]),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final SellerOrderSummaryItem order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const HugeIcon(icon: HugeIcons.strokeRoundedReceipt),
        title: Text(order.customerName),
        subtitle: Text(order.status),
        trailing: Text('₹${order.totalAmount.toStringAsFixed(0)}'),
      ),
    );
  }
}
