import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:society_seva/features/seller/presentation/dashboard/widgets/seller_empty_state.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';

// ---------------------------------------------------------------------------
// Model — shaped for once a "my reviews" endpoint exists.
// ---------------------------------------------------------------------------
class SellerReviewItem {
  const SellerReviewItem({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
  });

  final String id;
  final String customerName;
  final int rating;
  final String comment;
}

// ---------------------------------------------------------------------------
// Provider — TODO: replace with the real "my reviews" API call once one
// exists. The rating/total below come from the already-loaded seller
// profile, so only this list is a placeholder.
// ---------------------------------------------------------------------------
final sellerReviewsListProvider = FutureProvider.autoDispose<List<SellerReviewItem>>((ref) async {
  return const [];
});

class SellerReviewsScreen extends ConsumerWidget {
  const SellerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seller = ref.watch(sellerProvider).value;
    final reviewsAsync = ref.watch(sellerReviewsListProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(sellerReviewsListProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Reviews',
            style: GoogleFonts.hind(
              textStyle: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          Card(
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
                          (seller == null || seller.totalReviews == 0)
                              ? 'No reviews yet'
                              : '${seller.averageRating.toStringAsFixed(1)} average rating',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${seller?.totalReviews ?? 0} total reviews',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Recent reviews', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          reviewsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SellerErrorRow(
              message: 'Could not load reviews',
              onRetry: () => ref.invalidate(sellerReviewsListProvider),
            ),
            data: (reviews) => reviews.isEmpty
                ? const SellerEmptyState(
                    icon: HugeIcons.strokeRoundedComment01,
                    title: 'No reviews yet',
                    message: 'Reviews from customers will show up here.',
                  )
                : Column(children: [for (final review in reviews) _ReviewTile(review: review)]),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final SellerReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const HugeIcon(icon: HugeIcons.strokeRoundedComment01),
        title: Text(review.customerName),
        subtitle: Text(review.comment),
        trailing: Text('${review.rating}★'),
      ),
    );
  }
}
