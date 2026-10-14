import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class SubmitSellerUseCase {
  SubmitSellerUseCase(this._repository);

  final SellerRepository _repository;

  Future<void> call(String sellerId) => _repository.submitSellerProfileRepo(sellerId);
}
