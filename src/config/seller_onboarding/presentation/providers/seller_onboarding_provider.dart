import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/core/providers/app_providers.dart';
import 'package:society_seva/features/seller_onboarding/data/datasources/seller_onboarding_remote_data_source.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/data/repositories/seller_onboarding_repository_impl.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/create_seller_draft_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/delete_seller_image_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/fetch_my_seller_profile_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/fetch_seller_images_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/submit_seller_profile_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/update_seller_draft_usecase.dart';
import 'package:society_seva/features/seller_onboarding/domain/usecases/upload_seller_image_usecase.dart';

// --- Dependency injection chain -------------------------------------------

final sellerOnboardingRemoteDataSourceProvider = Provider<SellerOnboardingRemoteDataSource>((
  ref,
) {
  return SellerOnboardingRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final sellerOnboardingRepositoryProvider = Provider<SellerOnboardingRepository>((ref) {
  return SellerOnboardingRepositoryImpl(
    remoteDataSource: ref.watch(sellerOnboardingRemoteDataSourceProvider),
  );
});

final fetchMySellerProfileUseCaseProvider = Provider<FetchMySellerProfileUseCase>((ref) {
  return FetchMySellerProfileUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final createSellerDraftUseCaseProvider = Provider<CreateSellerDraftUseCase>((ref) {
  return CreateSellerDraftUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final updateSellerDraftUseCaseProvider = Provider<UpdateSellerDraftUseCase>((ref) {
  return UpdateSellerDraftUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final submitSellerProfileUseCaseProvider = Provider<SubmitSellerProfileUseCase>((ref) {
  return SubmitSellerProfileUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final fetchSellerImagesUseCaseProvider = Provider<FetchSellerImagesUseCase>((ref) {
  return FetchSellerImagesUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final uploadSellerImageUseCaseProvider = Provider<UploadSellerImageUseCase>((ref) {
  return UploadSellerImageUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

final deleteSellerImageUseCaseProvider = Provider<DeleteSellerImageUseCase>((ref) {
  return DeleteSellerImageUseCase(ref.watch(sellerOnboardingRepositoryProvider));
});

// --- Read state: the current user's seller profile (if any) ---------------

final sellerOnboardingProfileProvider =
    AsyncNotifierProvider<SellerOnboardingProfileNotifier, SellerProfileEntity?>(
      SellerOnboardingProfileNotifier.new,
    );

class SellerOnboardingProfileNotifier extends AsyncNotifier<SellerProfileEntity?> {
  @override
  Future<SellerProfileEntity?> build() {
    return ref.read(fetchMySellerProfileUseCaseProvider).call();
  }
}

final sellerOnboardingImagesProvider = FutureProvider.family<List<SellerImageEntity>, String>((
  ref,
  sellerId,
) {
  return ref.read(fetchSellerImagesUseCaseProvider).call(sellerId);
});

// --- Action state: save-as-draft / submit / local photo picks -------------

class SellerOnboardingActionState {
  const SellerOnboardingActionState({
    this.sellerId,
    this.isSaving = false,
    this.isSubmitting = false,
    this.isUploadingImages = false,
    this.isDeletingImages = false,
    this.pendingImages = const [],
    this.pendingImageDeletions = const {},
    this.error,
  });

  final String? sellerId;
  final bool isSaving;
  final bool isSubmitting;
  final bool isUploadingImages;
  final bool isDeletingImages;
  final List<XFile> pendingImages;

  /// Ids of already-uploaded images the user has marked for removal. They
  /// stay visible (dimmed, with an undo option) until Save/Submit actually
  /// calls the delete API — removing a tile never fires a network call by
  /// itself.
  final Set<String> pendingImageDeletions;
  final Object? error;

  bool get isBusy => isSaving || isSubmitting || isUploadingImages || isDeletingImages;
  bool get hasDraft => sellerId != null;

  SellerOnboardingActionState copyWith({
    String? sellerId,
    bool? isSaving,
    bool? isSubmitting,
    bool? isUploadingImages,
    bool? isDeletingImages,
    List<XFile>? pendingImages,
    Set<String>? pendingImageDeletions,
    Object? error,
    bool clearError = false,
  }) {
    return SellerOnboardingActionState(
      sellerId: sellerId ?? this.sellerId,
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      isDeletingImages: isDeletingImages ?? this.isDeletingImages,
      pendingImages: pendingImages ?? this.pendingImages,
      pendingImageDeletions: pendingImageDeletions ?? this.pendingImageDeletions,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final sellerOnboardingActionProvider =
    NotifierProvider<SellerOnboardingActionNotifier, SellerOnboardingActionState>(
      SellerOnboardingActionNotifier.new,
    );

class SellerOnboardingActionNotifier extends Notifier<SellerOnboardingActionState> {
  @override
  SellerOnboardingActionState build() => const SellerOnboardingActionState();

  /// Called once the preloaded profile arrives, so Save/Submit know a draft
  /// already exists instead of trying to create a second one.
  void seed(String? sellerId) {
    if (sellerId == null || state.sellerId == sellerId) return;
    state = state.copyWith(sellerId: sellerId);
  }

  void addPendingImage(XFile file) =>
      state = state.copyWith(pendingImages: [...state.pendingImages, file]);

  void removePendingImage(XFile file) => state = state.copyWith(
    pendingImages: state.pendingImages.where((f) => f.path != file.path).toList(),
  );

  /// Stages an already-uploaded image for deletion. No network call happens
  /// here — the image stays in the grid (marked, with an undo option) until
  /// Save/Submit runs.
  void markImageForRemoval(String imageId) =>
      state = state.copyWith(pendingImageDeletions: {...state.pendingImageDeletions, imageId});

  void unmarkImageForRemoval(String imageId) => state = state.copyWith(
    pendingImageDeletions: state.pendingImageDeletions.where((id) => id != imageId).toSet(),
  );

  /// Save button: creates the draft if none exists yet, otherwise overwrites
  /// the existing one with the current form values. Either way, any locally
  /// picked photos are uploaded and any images marked for removal are
  /// deleted, once a seller id is available.
  Future<bool> saveDraft(SellerProfileRequest request) => _run(
    start: () => state = state.copyWith(isSaving: true, clearError: true),
    stop: () => state = state.copyWith(isSaving: false),
    action: () async {
      final existingId = state.sellerId;
      final sellerId = existingId == null
          ? await _createDraft(request)
          : await _updateDraft(existingId, request);
      await _uploadPendingImages(sellerId);
      await _deletePendingRemovals(sellerId);
    },
  );

  /// Submit button: if a draft already exists, only its id is sent to the
  /// submit endpoint — the already-saved draft data is what gets submitted.
  /// If there's no draft yet, one is created first and then submitted, so a
  /// single tap chains both API calls.
  Future<bool> submitDraft(SellerProfileRequest request) => _run(
    start: () => state = state.copyWith(isSubmitting: true, clearError: true),
    stop: () => state = state.copyWith(isSubmitting: false),
    action: () async {
      final sellerId = state.sellerId ?? await _createDraft(request);
      await _uploadPendingImages(sellerId);
      await _deletePendingRemovals(sellerId);
      await ref.read(submitSellerProfileUseCaseProvider).call(sellerId);
    },
  );

  Future<String> _createDraft(SellerProfileRequest request) async {
    final created = await ref.read(createSellerDraftUseCaseProvider).call(request);
    state = state.copyWith(sellerId: created.id);
    return created.id;
  }

  Future<String> _updateDraft(String sellerId, SellerProfileRequest request) async {
    await ref.read(updateSellerDraftUseCaseProvider).call(sellerId, request);
    return sellerId;
  }

  /// Uploads every locally stored photo, one call per pending file — the
  /// number of upload calls matches `pendingImages.length` exactly. A file
  /// is only removed from the pending list once its upload succeeds, so a
  /// partial failure leaves the rest queued for retry.
  Future<void> _uploadPendingImages(String sellerId) async {
    if (state.pendingImages.isEmpty) return;

    state = state.copyWith(isUploadingImages: true);
    try {
      for (final file in List.of(state.pendingImages)) {
        await ref.read(uploadSellerImageUseCaseProvider).call(sellerId, file);
        removePendingImage(file);
      }
    } finally {
      state = state.copyWith(isUploadingImages: false);
      ref.invalidate(sellerOnboardingImagesProvider(sellerId));
    }
  }

  /// Deletes every image staged for removal, one call per id. An id is only
  /// dropped from `pendingImageDeletions` once its delete call succeeds, so
  /// a partial failure leaves the rest staged for the next attempt.
  Future<void> _deletePendingRemovals(String sellerId) async {
    if (state.pendingImageDeletions.isEmpty) return;

    state = state.copyWith(isDeletingImages: true);
    try {
      for (final imageId in List.of(state.pendingImageDeletions)) {
        await ref.read(deleteSellerImageUseCaseProvider).call(sellerId, imageId);
        unmarkImageForRemoval(imageId);
      }
    } finally {
      state = state.copyWith(isDeletingImages: false);
      ref.invalidate(sellerOnboardingImagesProvider(sellerId));
    }
  }

  Future<bool> _run({
    required void Function() start,
    required void Function() stop,
    required Future<void> Function() action,
  }) async {
    start();
    try {
      await action();
      ref.invalidate(sellerOnboardingProfileProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: e);
      return false;
    } finally {
      stop();
    }
  }
}
