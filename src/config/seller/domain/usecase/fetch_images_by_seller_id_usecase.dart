import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class FetchImagesBySellerIdUsecase {
  FetchImagesBySellerIdUsecase(this._repository);

  final SellerRepository _repository;

  Future<void> call({required String sellerId}) => _repository.fetchSellerImagesRepo(sellerId);
}
