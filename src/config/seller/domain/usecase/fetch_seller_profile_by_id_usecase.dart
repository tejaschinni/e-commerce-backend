import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class FetchSellerProfileByIdUsecase {
  FetchSellerProfileByIdUsecase(this._repository);

  final SellerRepository _repository;

  Future<SellerProfileEntity?> call() => _repository.sellerProfile();
}
