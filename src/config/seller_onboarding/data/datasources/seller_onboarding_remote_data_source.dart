import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/core/network/api_client.dart';
import 'package:society_seva/core/network/api_endpoints.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_image_model.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_model.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';

abstract class SellerOnboardingRemoteDataSource {
  Future<SellerProfileModel?> myProfile();
  Future<SellerProfileModel> createDraft(SellerProfileRequest request);
  Future<SellerProfileModel> updateDraft(String sellerId, SellerProfileRequest request);
  Future<SellerProfileModel> submit(String sellerId);
  Future<List<SellerImageModel>> fetchImages(String sellerId);
  Future<void> uploadImage(String sellerId, XFile file);
  Future<void> deleteImage(String sellerId, String imageId);
}

class SellerOnboardingRemoteDataSourceImpl implements SellerOnboardingRemoteDataSource {
  SellerOnboardingRemoteDataSourceImpl({required this._apiClient});

  final ApiClient _apiClient;

  @override
  Future<SellerProfileModel?> myProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.sellerProfile);
      return SellerProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<SellerProfileModel> createDraft(SellerProfileRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.createSellerProfile,
      data: request.toJson(),
    );
    return SellerProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SellerProfileModel> updateDraft(String sellerId, SellerProfileRequest request) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.createSellerProfile}/$sellerId',
      data: request.toJson(),
    );
    return SellerProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SellerProfileModel> submit(String sellerId) async {
    final response = await _apiClient.post(ApiEndpoints.submitSellerProfile(sellerId));
    return SellerProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SellerImageModel>> fetchImages(String sellerId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fetchSellerImages(sellerId));
      final data = response.data as List<dynamic>;
      return data.map((item) => SellerImageModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  @override
  Future<void> uploadImage(String sellerId, XFile file) async {
    final form = FormData();
    form.files.add(
      MapEntry('file', await MultipartFile.fromFile(file.path, filename: file.name)),
    );
    await _apiClient.post(ApiEndpoints.fetchSellerImages(sellerId), data: form);
  }

  @override
  Future<void> deleteImage(String sellerId, String imageId) async {
    await _apiClient.delete('${ApiEndpoints.fetchSellerImages(sellerId)}/$imageId');
  }
}
