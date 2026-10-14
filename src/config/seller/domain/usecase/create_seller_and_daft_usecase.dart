import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class CreateSellerAndDaftUsecase {
  CreateSellerAndDaftUsecase(this._repository);

  final SellerRepository _repository;

  Future<void> call({required SellerProfileRequest request}) =>
      _repository.createProfileRepo(request: request);
}
