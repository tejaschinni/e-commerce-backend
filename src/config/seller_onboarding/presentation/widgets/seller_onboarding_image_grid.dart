import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller_onboarding/presentation/providers/seller_onboarding_provider.dart';

/// Shows locally picked (not-yet-uploaded) photos together with photos
/// already uploaded for the current draft. The seller id comes from
/// [sellerOnboardingActionProvider] rather than a constructor argument, so
/// the grid switches from "local only" to "fetching uploaded photos" the
/// moment Save/Submit creates the draft, with no extra wiring needed.
///
/// Removing a photo never calls the API directly: a locally-picked photo is
/// just dropped from the pending list, and an already-uploaded photo is
/// marked for removal (dimmed, with an undo option) — the actual delete
/// call only happens when Save/Submit next runs.
class SellerOnboardingImageGrid extends ConsumerStatefulWidget {
  const SellerOnboardingImageGrid({super.key});

  @override
  ConsumerState<SellerOnboardingImageGrid> createState() => _SellerOnboardingImageGridState();
}

class _SellerOnboardingImageGridState extends ConsumerState<SellerOnboardingImageGrid> {
  // Change these two together: 3 columns -> show 3 (one row), 4 columns -> show 4.
  static const _columns = 3;
  static const _collapsedCount = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(sellerOnboardingActionProvider);
    final pending = action.pendingImages;
    final pendingDeletions = action.pendingImageDeletions;
    final isBusy = action.isBusy;
    final sellerId = action.sellerId;

    if (sellerId == null) {
      if (pending.isEmpty) {
        return _emptyHint('Save as draft to enable photo upload');
      }
      return _grid(uploaded: const [], pending: pending, pendingDeletions: pendingDeletions, isBusy: isBusy);
    }

    final images = ref.watch(sellerOnboardingImagesProvider(sellerId));

    return images.when(
      skipLoadingOnRefresh: true,
      loading: () => pending.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          : _grid(uploaded: const [], pending: pending, pendingDeletions: pendingDeletions, isBusy: isBusy),
      error: (e, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedCloudOff, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Could not load photos')),
                TextButton.icon(
                  onPressed: () => ref.invalidate(sellerOnboardingImagesProvider(sellerId)),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh01, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          if (pending.isNotEmpty)
            _grid(uploaded: const [], pending: pending, pendingDeletions: pendingDeletions, isBusy: isBusy),
        ],
      ),
      data: (list) => _grid(uploaded: list, pending: pending, pendingDeletions: pendingDeletions, isBusy: isBusy),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedImage02,
            size: 18,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ),
        ],
      ),
    );
  }

  Widget _grid({
    required List<SellerImageEntity> uploaded,
    required List<XFile> pending,
    required Set<String> pendingDeletions,
    required bool isBusy,
  }) {
    final total = pending.length + uploaded.length;

    if (total == 0) {
      return _emptyHint('No photos yet');
    }

    final canExpand = total > _collapsedCount;
    final visibleCount = (_expanded || !canExpand) ? total : _collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            // Pending (locally picked) images come first, then uploaded ones.
            if (i < pending.length) {
              return _pendingTile(pending[i], isBusy);
            }
            final image = uploaded[i - pending.length];
            final markedForRemoval = pendingDeletions.contains(image.id);
            return _uploadedTile(image, markedForRemoval: markedForRemoval, isBusy: isBusy);
          },
        ),
        if (canExpand)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: HugeIcon(
              icon: _expanded ? HugeIcons.strokeRoundedArrowUp01 : HugeIcons.strokeRoundedArrowDown01,
              size: 16,
            ),
            label: Text(_expanded ? 'Show less' : 'View all ($total)'),
          ),
      ],
    );
  }

  Widget _tileShell({required Widget image, required Widget? badge, Widget? action}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
        if (badge != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: badge,
            ),
          ),
        if (action != null) Positioned(top: 4, right: 4, child: action),
      ],
    );
  }

  Widget _badgeLabel(String text, {Color background = Colors.black54}) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _roundIconButton({
    required List<List<dynamic>> icon,
    required bool disabled,
    required VoidCallback onTap,
    Color enabledColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: disabled ? Colors.grey : enabledColor,
        child: HugeIcon(icon: icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _uploadedTile(SellerImageEntity image, {required bool markedForRemoval, required bool isBusy}) {
    final photo = GestureDetector(
      key: ValueKey(image.id),
      onTap: markedForRemoval
          ? null
          : () => showDialog(
              context: context,
              builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(image.imageUrl))),
            ),
      child: ColorFiltered(
        colorFilter: markedForRemoval
            ? const ColorFilter.mode(Colors.black54, BlendMode.darken)
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Image.network(
          image.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01)),
        ),
      ),
    );

    if (markedForRemoval) {
      return _tileShell(
        image: photo,
        badge: _badgeLabel('Will be removed', background: Colors.red.shade700.withValues(alpha: 0.85)),
        action: _roundIconButton(
          icon: HugeIcons.strokeRoundedUndo,
          disabled: isBusy,
          enabledColor: Colors.black87,
          onTap: () => ref.read(sellerOnboardingActionProvider.notifier).unmarkImageForRemoval(image.id),
        ),
      );
    }

    return _tileShell(
      image: photo,
      badge: null,
      action: _roundIconButton(
        icon: HugeIcons.strokeRoundedDelete01,
        disabled: isBusy,
        onTap: () => ref.read(sellerOnboardingActionProvider.notifier).markImageForRemoval(image.id),
      ),
    );
  }

  Widget _pendingTile(XFile file, bool isBusy) {
    return _tileShell(
      image: Image.file(File(file.path), fit: BoxFit.cover, key: ValueKey(file.path)),
      badge: _badgeLabel('Pending upload'),
      action: _roundIconButton(
        icon: HugeIcons.strokeRoundedDelete01,
        disabled: isBusy,
        onTap: () => ref.read(sellerOnboardingActionProvider.notifier).removePendingImage(file),
      ),
    );
  }
}
