import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';

class UploadImagesBySellerIdUsecase {
  UploadImagesBySellerIdUsecase(this._repository);

  final SellerRepository _repository;

  Future<void> call({required String sellerId, required XFile file}) =>
      _repository.uploadSellerImageRepo(sellerId, file);
}
