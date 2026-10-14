class SellerProfileRequest {
  final String userId;
  final int? societyId;
  final String displayName;
  final String? businessName;
  final String sellerType;
  final String? bio;
  final bool? fssaiRequired;
  final String? fssaiCertificateId;
  final String? socialMediaLinks;
  final String? websiteUrl;
  final String? legalCompliance;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final double? latitude;
  final double? longitude;
  final String? geofencePolygon;
  final double? deliveryRadiusKm;
  final String? targetArea;

  const SellerProfileRequest({
    required this.userId,
    this.societyId,
    required this.displayName,
    this.businessName,
    required this.sellerType,
    this.bio,
    this.fssaiRequired,
    this.fssaiCertificateId,
    this.socialMediaLinks,
    this.websiteUrl,
    this.legalCompliance,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    this.latitude,
    this.longitude,
    this.geofencePolygon,
    this.deliveryRadiusKm,
    this.targetArea,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'societyId': societyId,
      'displayName': displayName,
      'businessName': businessName,
      'sellerType': sellerType,
      'bio': bio,
      'fssaiRequired': fssaiRequired,
      'fssaiCertificateId': fssaiCertificateId,
      'socialMediaLinks': socialMediaLinks,
      'websiteUrl': websiteUrl,
      'legalCompliance': legalCompliance,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'latitude': latitude,
      'longitude': longitude,
      'geofencePolygon': geofencePolygon,
      'deliveryRadiusKm': deliveryRadiusKm,
      'targetArea': targetArea,
    };
    // Drop optional fields that are empty so the backend sees them as absent.
    map.removeWhere((key, value) => value == null || (value is String && value.trim().isEmpty));
    return map;
  }
}
