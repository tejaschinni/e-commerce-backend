import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class CreateSellerDraftUseCase {
  CreateSellerDraftUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<SellerProfileEntity> call(SellerProfileRequest request) =>
      _repository.createDraft(request);
}
