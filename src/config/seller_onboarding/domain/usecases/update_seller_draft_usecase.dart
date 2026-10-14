import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class UpdateSellerDraftUseCase {
  UpdateSellerDraftUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<SellerProfileEntity> call(String sellerId, SellerProfileRequest request) =>
      _repository.updateDraft(sellerId, request);
}
