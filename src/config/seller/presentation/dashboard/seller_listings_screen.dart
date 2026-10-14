import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:society_seva/features/seller/presentation/dashboard/widgets/seller_empty_state.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';

// ---------------------------------------------------------------------------
// Model — shaped for once a "my listings" endpoint exists.
// ---------------------------------------------------------------------------
class SellerListingSummary {
  const SellerListingSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
    required this.price,
  });

  final String id;
  final String name;
  final String type; // PRODUCT | SERVICE
  final bool isAvailable;
  final double price;
}

// ---------------------------------------------------------------------------
// Provider — TODO: replace with the real "my listings" API call once one
// exists. Until then this resolves to an empty list so the screen below is
// fully wired and only needs real data dropped in.
// ---------------------------------------------------------------------------
final sellerListingsProvider = FutureProvider.autoDispose<List<SellerListingSummary>>((ref) async {
  return const [];
});

class SellerListingsScreen extends ConsumerWidget {
  const SellerListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(sellerListingsProvider);
    final totalListings = ref.watch(sellerProvider).value?.totalListings ?? 0;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(sellerListingsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listings',
                      style: GoogleFonts.hind(
                        textStyle: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('$totalListings active', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _comingSoon(context),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedPackageAdd01, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          listingsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SellerErrorRow(
              message: 'Could not load listings',
              onRetry: () => ref.invalidate(sellerListingsProvider),
            ),
            data: (listings) => listings.isEmpty
                ? const SellerEmptyState(
                    icon: HugeIcons.strokeRoundedPackage01,
                    title: 'No listings yet',
                    message: 'Add your first product or service so customers can find you.',
                  )
                : Column(children: [for (final listing in listings) _ListingTile(listing: listing)]),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Adding listings is coming soon')));
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.listing});
  final SellerListingSummary listing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const HugeIcon(icon: HugeIcons.strokeRoundedPackage01),
        title: Text(listing.name),
        subtitle: Text(listing.type),
        trailing: Text('₹${listing.price.toStringAsFixed(0)}'),
      ),
    );
  }
}
