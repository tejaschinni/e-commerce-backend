class SellerImageEntity {
  final String id;
  final String sellerId;
  final String imageUrl;
  final String moderationStatus;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerImageEntity({
    required this.id,
    required this.sellerId,
    required this.imageUrl,
    required this.moderationStatus,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  SellerImageEntity copyWith({
    String? id,
    String? sellerId,
    String? imageUrl,
    String? moderationStatus,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerImageEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      imageUrl: imageUrl ?? this.imageUrl,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
