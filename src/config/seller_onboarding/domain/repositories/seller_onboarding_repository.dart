import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';

abstract class SellerOnboardingRepository {
  /// The current user's seller profile, or null if they've never applied.
  Future<SellerProfileEntity?> fetchMyProfile();

  /// Creates a new DRAFT seller profile and returns it (with its id).
  Future<SellerProfileEntity> createDraft(SellerProfileRequest request);

  /// Overwrites an existing DRAFT (or rejected) seller profile with the
  /// current form values.
  Future<SellerProfileEntity> updateDraft(String sellerId, SellerProfileRequest request);

  /// Moves a seller profile from DRAFT to PENDING review.
  Future<SellerProfileEntity> submit(String sellerId);

  Future<List<SellerImageEntity>> fetchImages(String sellerId);

  Future<void> uploadImage(String sellerId, XFile file);

  Future<void> deleteImage(String sellerId, String imageId);
}
