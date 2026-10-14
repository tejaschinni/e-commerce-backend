import '../../domain/entities/seller_image_entity.dart';

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
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      imageUrl: json['imageUrl'] as String,
      moderationStatus: json['moderationStatus'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory SellerImageModel.fromEntity(SellerImageEntity entity) {
    return SellerImageModel(
      id: entity.id,
      sellerId: entity.sellerId,
      imageUrl: entity.imageUrl,
      moderationStatus: entity.moderationStatus,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SellerImageEntity toEntity() {
    return SellerImageEntity(
      id: id,
      sellerId: sellerId,
      imageUrl: imageUrl,
      moderationStatus: moderationStatus,
      displayOrder: displayOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  SellerImageModel copyWith({
    String? id,
    String? sellerId,
    String? imageUrl,
    String? moderationStatus,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerImageModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      imageUrl: imageUrl ?? this.imageUrl,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'imageUrl': imageUrl,
      'moderationStatus': moderationStatus,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
