import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';

class ImageGridWidget extends ConsumerStatefulWidget {
  const ImageGridWidget({super.key, this.sellerId});

  final String? sellerId; // null until the draft exists

  @override
  ConsumerState<ImageGridWidget> createState() => _ImageGridWidgetState();
}

class _ImageGridWidgetState extends ConsumerState<ImageGridWidget> {
  // Change these two together: 3 columns -> show 3 (one row), 4 columns -> show 4.
  static const _columns = 3;
  static const _collapsedCount = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(sellerActionProvider.select((s) => s.pendingImages));
    final isBusy = ref.watch(sellerActionProvider.select((s) => s.isBusy));

    final id = widget.sellerId;
    if (id == null) {
      return _grid(uploaded: const [], pending: pending, isBusy: isBusy);
    }

    final images = ref.watch(sellerImagesProvider(id));

    return images.when(
      skipLoadingOnRefresh: true,
      loading: () => pending.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          : _grid(uploaded: const [], pending: pending, isBusy: isBusy),
      error: (e, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Expanded(child: Text('Could not load photos')),
                TextButton(
                  onPressed: () => ref.invalidate(sellerImagesProvider(id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          if (pending.isNotEmpty) _grid(uploaded: const [], pending: pending, isBusy: isBusy),
        ],
      ),
      data: (list) => _grid(uploaded: list ?? const [], pending: pending, isBusy: isBusy),
    );
  }

  Widget _grid({
    required List<SellerImageEntity> uploaded,
    required List<XFile> pending,
    required bool isBusy,
  }) {
    final total = pending.length + uploaded.length;

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No photos yet'),
      );
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
            // Pending images come first, then uploaded ones.
            if (i < pending.length) {
              return _pendingTile(pending[i], isBusy);
            }
            return _uploadedTile(uploaded[i - pending.length].imageUrl);
          },
        ),
        if (canExpand)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(_expanded ? 'Show less' : 'View all ($total)'),
          ),
      ],
    );
  }

  Widget _uploadedTile(String url) {
    return GestureDetector(
      key: ValueKey(url),
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(url))),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _pendingTile(XFile file, bool isBusy) {
    return Stack(
      key: ValueKey(file.path),
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(file.path), fit: BoxFit.cover),
        ),
        // "Pending" label
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: const Text(
                'Pending',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
        // remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: isBusy
                ? null // can't remove while an upload is running
                : () => ref.read(sellerActionProvider.notifier).removePendingImage(file),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: isBusy ? Colors.grey : Colors.black87,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
