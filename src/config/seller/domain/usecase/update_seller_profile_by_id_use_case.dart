import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class UpdateSellerProfileByIdUseCase {
  UpdateSellerProfileByIdUseCase(this._repository);

  final SellerRepository _repository;

  Future<SellerProfileEntity?> call({
    required SellerProfileRequest request,
    required String sellerId,
  }) => _repository.updateProfileRepo(request: request, sellerID: sellerId);
}
