import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller_onboarding/data/datasources/seller_onboarding_remote_data_source.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class SellerOnboardingRepositoryImpl implements SellerOnboardingRepository {
  SellerOnboardingRepositoryImpl({required this._remoteDataSource});

  final SellerOnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<SellerProfileEntity?> fetchMyProfile() async {
    final model = await _remoteDataSource.myProfile();
    return model?.toEntity();
  }

  @override
  Future<SellerProfileEntity> createDraft(SellerProfileRequest request) async {
    final model = await _remoteDataSource.createDraft(request);
    return model.toEntity();
  }

  @override
  Future<SellerProfileEntity> updateDraft(String sellerId, SellerProfileRequest request) async {
    final model = await _remoteDataSource.updateDraft(sellerId, request);
    return model.toEntity();
  }

  @override
  Future<SellerProfileEntity> submit(String sellerId) async {
    final model = await _remoteDataSource.submit(sellerId);
    return model.toEntity();
  }

  @override
  Future<List<SellerImageEntity>> fetchImages(String sellerId) async {
    final models = await _remoteDataSource.fetchImages(sellerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> uploadImage(String sellerId, XFile file) {
    return _remoteDataSource.uploadImage(sellerId, file);
  }

  @override
  Future<void> deleteImage(String sellerId, String imageId) {
    return _remoteDataSource.deleteImage(sellerId, imageId);
  }
}
