import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller_onboarding/domain/repositories/seller_onboarding_repository.dart';

class UploadSellerImageUseCase {
  UploadSellerImageUseCase(this._repository);

  final SellerOnboardingRepository _repository;

  Future<void> call(String sellerId, XFile file) => _repository.uploadImage(sellerId, file);
}
