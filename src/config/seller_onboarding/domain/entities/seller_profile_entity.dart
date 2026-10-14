class SellerProfileEntity {
  final String id;
  final String userId;
  final String displayName;
  final String sellerType;
  final String availabilityStatus;
  final String approvalStatus;
  final String fssaiStatus;
  final bool fssaiRequired;
  final String renewalStatus;
  final int totalListings;
  final double averageRating;
  final int rejectedOrders;
  final int cancelledOrders;
  final int totalOrders;
  final int totalReviews;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final String createdAt;
  final String updatedAt;
  final String? societyId;
  final String? businessName;
  final String? bio;
  final String? fssaiCertificateId;
  final String? socialMediaLinks;
  final String? websiteUrl;
  final String? legalCompliance;
  final double? latitude;
  final double? longitude;
  final String? geofencePolygon;
  final double? deliveryRadiusKm;
  final String? targetArea;

  const SellerProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.sellerType,
    required this.availabilityStatus,
    required this.approvalStatus,
    required this.fssaiStatus,
    required this.fssaiRequired,
    required this.renewalStatus,
    required this.totalListings,
    required this.averageRating,
    required this.rejectedOrders,
    required this.cancelledOrders,
    required this.totalOrders,
    required this.totalReviews,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.createdAt,
    required this.updatedAt,
    this.societyId,
    this.businessName,
    this.bio,
    this.fssaiCertificateId,
    this.socialMediaLinks,
    this.websiteUrl,
    this.legalCompliance,
    this.latitude,
    this.longitude,
    this.geofencePolygon,
    this.deliveryRadiusKm,
    this.targetArea,
  });

  bool get isDraft => approvalStatus.toUpperCase() == 'DRAFT';
  bool get isPending => approvalStatus.toUpperCase() == 'PENDING';
  bool get isApproved => approvalStatus.toUpperCase() == 'APPROVED';
}
