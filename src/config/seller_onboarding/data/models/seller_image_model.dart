import 'package:society_seva/features/seller_onboarding/domain/entities/seller_image_entity.dart';

class SellerImageModel extends SellerImageEntity {
  const SellerImageModel({
    required super.id,
    required super.sellerId,
    required super.imageUrl,
    required super.moderationStatus,
    required super.displayOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SellerImageModel.fromJson(Map<String, dynamic> json) {
    return SellerImageModel(
      id: json['id'].toString(),
      sellerId: json['sellerId'].toString(),
      imageUrl: json['imageUrl'] as String? ?? '',
      moderationStatus: json['moderationStatus'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  SellerImageEntity toEntity() => this;
}
