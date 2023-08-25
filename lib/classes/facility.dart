class TwysheFacility {
  final int facilityId;
  final String facilityName;
  final String facilityAddress;
  final String facilityPhone;
  final String facilityThumbnailUrl;

  const TwysheFacility({
    required this.facilityId,
    required this.facilityName,
    required this.facilityAddress,
    required this.facilityPhone,
    required this.facilityThumbnailUrl,
  });

  factory TwysheFacility.fromJson(Map<String, dynamic> json) {
    return TwysheFacility(
      facilityId: json['facility_id'] as int,
      facilityName: json['facility_name'] as String,
      facilityAddress: json['facility_description'] as String,
      facilityPhone: json['facility_url'] as String,
      facilityThumbnailUrl: json['facility_thumbnailUrl'] as String,
    );
  }
}