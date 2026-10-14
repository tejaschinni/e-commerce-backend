import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/core/providers/app_providers.dart';
import 'package:society_seva/features/seller/data/datasources/seller_remote_data_source.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';
import 'package:society_seva/features/seller/domain/usecase/fetch_seller_profile_usecase.dart';

final sellerRemoteDataSource = Provider<SellerRemoteDataSource>((ref) {
  return SellerRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final sellerRepository = Provider<SellerRepository>((ref) {
  return SellerRepositoryImpl(sellerRemoteDataSource: ref.watch(sellerRemoteDataSource));
});

final fetchSellerProfileUseCase = Provider<FetchSellerProfileUseCase>((ref) {
  return FetchSellerProfileUseCase(ref.watch(sellerRepository));
});

final sellerProvider = AsyncNotifierProvider<SellerNotifier, SellerProfileEntity?>(
  SellerNotifier.new,
);
final sellerImagesProvider = FutureProvider.family<List<SellerImageEntity>?, String>((
  ref,
  sellerId,
) {
  return ref.read(sellerRepository).fetchSellerImagesRepo(sellerId);
});

class SellerNotifier extends AsyncNotifier<SellerProfileEntity?> {
  @override
  Future<SellerProfileEntity?> build() async {
    try {
      return await ref.read(sellerRepository).sellerProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

final sellerActionProvider = NotifierProvider<SellerActionNotifier, SellerActionState>(
  SellerActionNotifier.new,
);

class SellerActionNotifier extends Notifier<SellerActionState> {
  SellerRepository get _repo => ref.read(sellerRepository);

  @override
  SellerActionState build() => const SellerActionState();

  void addPendingImage(XFile file) =>
      state = state.copyWith(pendingImages: [...state.pendingImages, file]);

  void removePendingImage(XFile file) => state = state.copyWith(
    pendingImages: state.pendingImages.where((f) => f.path != file.path).toList(),
  );

  Future<void> _uploadPendingImages(String sellerId) async {
    try {
      for (final file in List.of(state.pendingImages)) {
        await _repo.uploadSellerImageRepo(sellerId, file);
        removePendingImage(file);
      }
    } finally {
      // also runs after a partial failure, so images that did upload still show
      ref.invalidate(sellerImagesProvider(sellerId));
    }
  }

  Future<String> _createDraft(SellerProfileRequest request) async {
    await _repo.createProfileRepo(request: request);

    final seller = await ref.refresh(sellerProvider.future);
    if (seller == null) {
      throw Exception('Draft was saved but the seller profile could not be loaded.');
    }
    return seller.id.toString();
  }

  Future<bool> save(SellerProfileRequest request) => _run(
    start: () => state = state.copyWith(isSaving: true, clearError: true),
    stop: () => state = state.copyWith(isSaving: false),
    action: () async {
      final sellerId = await _createDraft(request); // profile is refreshed here
      await _uploadPendingImages(sellerId); // no-op when there are no images
    },
    refreshProfile: true,
  );

  Future<bool> submitSellerProfile(String id) => _run(
    start: () => state = state.copyWith(isSubmitting: true, clearError: true),
    stop: () => state = state.copyWith(isSubmitting: false),
    action: () async {
      await _repo.submitSellerProfileRepo(id);
      ref.invalidate(sellerImagesProvider(id));
    },
  );

  Future<bool> updateSellerProfile(SellerProfileRequest request, String id) => _run(
    start: () => state = state.copyWith(isSubmitting: true, clearError: true),
    stop: () => state = state.copyWith(isSubmitting: false),
    action: () async {
      await _repo.updateProfileRepo(request: request, sellerID: id);
      ref.invalidate(sellerImagesProvider(id));
    },
  );

  Future<bool> saveAndSubmit(SellerProfileRequest request) => _run(
    start: () => state = state.copyWith(isSubmitting: true, clearError: true),
    stop: () => state = state.copyWith(isSubmitting: false),
    action: () async {
      final existing = ref.read(sellerProvider).value;

      final String sellerId;
      if (existing != null) {
        sellerId = existing.id.toString();
        await submitSellerProfile(sellerId);
      } else {
        sellerId = await _createDraft(request);
      }

      await _uploadPendingImages(sellerId); // only runs if images are queued
      await _repo.submitSellerProfileRepo(sellerId);
    },
  );

  // direct upload, used when the seller already exists
  Future<bool> uploadImage(String sellerId, XFile file) => _run(
    start: () => state = state.copyWith(isUploading: true, clearError: true),
    stop: () => state = state.copyWith(isUploading: false),
    action: () => _repo.uploadSellerImageRepo(sellerId, file),
    refreshProfile: true,
  );
  Future<bool> _run({
    required void Function() start,
    required void Function() stop,
    required Future<void> Function() action,
    bool refreshProfile = true,
  }) async {
    start();
    try {
      await action();
      ref.invalidate(sellerProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: e);
      return false;
    } finally {
      stop();
    }
  }
}

class SellerActionState {
  const SellerActionState({
    this.isSaving = false,
    this.isSubmitting = false,
    this.isUploading = false,
    this.pendingImages = const [],
    this.error,
  });

  final bool isSaving;
  final bool isSubmitting;
  final bool isUploading;
  final List<XFile> pendingImages;
  final Object? error;

  bool get isBusy => isSaving || isSubmitting || isUploading;

  SellerActionState copyWith({
    bool? isSaving,
    bool? isSubmitting,
    bool? isUploading,
    List<XFile>? pendingImages,
    Object? error,
    bool clearError = false,
  }) {
    return SellerActionState(
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploading: isUploading ?? this.isUploading,
      pendingImages: pendingImages ?? this.pendingImages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
