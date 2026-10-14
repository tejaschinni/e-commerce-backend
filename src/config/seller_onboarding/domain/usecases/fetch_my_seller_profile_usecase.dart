import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class FetchMySellerProfileUseCase {
  FetchMySellerProfileUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<SellerProfileEntity?> call() => _repository.fetchMyProfile();
}
