import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class FetchSellerImagesUseCase {
  FetchSellerImagesUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<List<SellerImageEntity>> call(String sellerId) => _repository.fetchImages(sellerId);
}
