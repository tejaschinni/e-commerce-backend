import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/core/network/api_client.dart';
import 'package:society_seva/core/network/api_endpoints.dart';
import 'package:society_seva/features/seller/data/models/seller_image_model.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_model.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';

abstract class SellerRemoteDataSource {
  Future<SellerProfileModel?> createProfileDataSource({required SellerProfileRequest request});
  Future<SellerProfileModel?> submitSellerProfileDataSource(String userId);
  Future<void> uploadSellerImages(String sellerId, XFile file);
  Future<List<SellerImageModel>> fetchSellerImages(String sellerId);
  Future<SellerProfileModel?> sellerProfile();
  Future<void> getSellerById(String sellerID);
  Future<SellerProfileModel?> updateProfileDataSource({
    required SellerProfileRequest request,
    required String sellerID,
  });
}

class SellerRemoteDataSourceImpl implements SellerRemoteDataSource {
  SellerRemoteDataSourceImpl({required this._apiClient});

  final ApiClient _apiClient;
  @override
  Future<SellerProfileModel?> createProfileDataSource({
    required SellerProfileRequest request,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createSellerProfile,
        data: request.toJson(),
      );
      debugPrint("response for create seller profile ${response.data}");
      return SellerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<SellerProfileModel?> submitSellerProfileDataSource(String userId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.submitSellerProfile(userId));

      log("response for submitt the seller ${response.data}");
      return SellerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> uploadSellerImages(String sellerId, XFile file) async {
    final form = FormData();

    form.files.add(
      MapEntry(
        'file', // field name expected by Spring (@RequestPart / @RequestParam)
        await MultipartFile.fromFile(file.path, filename: file.name),
      ),
    );

    final response = await _apiClient.post(ApiEndpoints.fetchSellerImages(sellerId), data: form);

    log("respoinse for upload images ${response.data}");
  }

  @override
  Future<List<SellerImageModel>> fetchSellerImages(String sellerId) async {
    final response = await _apiClient.get(ApiEndpoints.fetchSellerImages(sellerId));
    log("Fetch image response ${response.data}");

    final List<dynamic> data = response.data as List<dynamic>;

    return data.map((item) => SellerImageModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<SellerProfileModel?> sellerProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.sellerProfile);
      log("Fetch seller profile ${response.data}");
      return SellerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<SellerProfileModel?> getSellerById(String sellerID) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.sellerByID(sellerID));
      log("fetch seller by ID ${response.data}");
      return SellerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<SellerProfileModel?> updateProfileDataSource({
    required SellerProfileRequest request,
    required String sellerID,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.createSellerProfile}/$sellerID',
        data: request.toJson(),
      );
      debugPrint("response for update seller profile ${response.data}");
      return SellerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
