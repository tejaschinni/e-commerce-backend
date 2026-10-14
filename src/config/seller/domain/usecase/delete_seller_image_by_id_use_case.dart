import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class DeleteSellerImageByIdUseCase {
  DeleteSellerImageByIdUseCase(this._repository);

  final SellerRepository _repository;

  Future<void> call({required String imageId, required String sellerId}) =>
      _repository.deleteSellerImageRepo(imageID: imageId, sellerID: sellerId);
}
