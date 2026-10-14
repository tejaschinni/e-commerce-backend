import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/seller/data/datasources/seller_remote_data_source.dart';
import 'package:society_seva/features/seller/data/models/seller_image_model.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_model.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';

abstract class SellerRepository {
  Future<void> createProfileRepo({required SellerProfileRequest request});
  Future<void> submitSellerProfileRepo(String userId);
  Future<SellerProfileEntity?> sellerProfile();
  Future<void> uploadSellerImageRepo(String sellerId, XFile file);
  Future<List<SellerImageModel>> fetchSellerImagesRepo(String sellerId);
  Future<SellerProfileModel?> updateProfileRepo({
    required SellerProfileRequest request,
    required String sellerID,
  });
  Future<void> deleteSellerImageRepo({required String imageID, required String sellerID});
}

class SellerRepositoryImpl implements SellerRepository {
  SellerRepositoryImpl({required this.sellerRemoteDataSource});
  final SellerRemoteDataSource sellerRemoteDataSource;
  @override
  Future<void> createProfileRepo({required SellerProfileRequest request}) async {
    await sellerRemoteDataSource.createProfileDataSource(request: request);
  }

  @override
  Future<void> submitSellerProfileRepo(String userId) async {
    await sellerRemoteDataSource.submitSellerProfileDataSource(userId);
  }

  @override
  Future<void> uploadSellerImageRepo(String sellerId, XFile file) async {
    await sellerRemoteDataSource.uploadSellerImages(sellerId, file);
  }

  @override
  Future<SellerProfileEntity?> sellerProfile() async {
    final model = await sellerRemoteDataSource.sellerProfile();
    return model?.toEntity();
  }

  @override
  Future<List<SellerImageModel>> fetchSellerImagesRepo(String sellerId) async {
    return await sellerRemoteDataSource.fetchSellerImages(sellerId);
  }

  @override
  Future<SellerProfileModel?> updateProfileRepo({
    required SellerProfileRequest request,
    required String sellerID,
  }) async {
    return await sellerRemoteDataSource.updateProfileDataSource(
      request: request,
      sellerID: sellerID,
    );
  }

  @override
  Future<void> deleteSellerImageRepo({required String imageID, required String sellerID}) {
    // TODO: implement deleteSellerImageRepo
    throw UnimplementedError();
  }
}
