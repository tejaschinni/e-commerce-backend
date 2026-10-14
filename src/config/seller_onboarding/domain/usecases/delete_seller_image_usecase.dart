import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class DeleteSellerImageUseCase {
  DeleteSellerImageUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<void> call(String sellerId, String imageId) => _repository.deleteImage(sellerId, imageId);
}
