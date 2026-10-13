import 'dart:io';

import 'package:flutter/material.dart';

/// Tappable image slot for the profile form.
///
/// Priority order: a freshly picked local file, then the previously
/// uploaded remote image, then a placeholder prompting the user to pick
/// one. An upload spinner overlays once a pick has been handed off to the
/// backend.
class ImagePickerPreviewWidget extends StatelessWidget {
  const ImagePickerPreviewWidget({
    super.key,
    required this.localImageFile,
    required this.remoteImageUrl,
    required this.isUploading,
    required this.onTap,
  });

  final File? localImageFile;
  final String? remoteImageUrl;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surfaceContainerHighest,
          border: Border.all(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _buildImage(),
            if (isUploading)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final local = localImageFile;
    if (local != null) {
      return Image.file(local, fit: BoxFit.cover);
    }
    final remote = remoteImageUrl;
    if (remote != null) {
      // The mock data source returns a placeholder host, so network loads
      // of it will fail by design - fall back to the placeholder icon
      // rather than showing a broken-image glyph.
      return Image.network(
        remote,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_outlined, size: 40),
      );
    }
    return const Icon(Icons.add_a_photo_outlined, size: 40);
  }
}
