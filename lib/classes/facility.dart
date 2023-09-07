class TwysheFacility {
  final int facilityId;
  final String facilityName;
  final String facilityAddress;
  final String facilityTollfree;
  final String facilityWhatsapp;
  final String facilityEmail;
  final String facilityWebsite;
  final String facilityPhone;
  final String facilityContraception;
  final String facilityPrep;
  final String facilityAbortion;
  final String facilityMenstrual;
  final String facilitySTI;
  final String facilityART;
  final String facilityThumbnailUrl;
  final double facilityLat;
  final double facilityLon;

  const TwysheFacility(
      {required this.facilityId,
      required this.facilityName,
      required this.facilityAddress,
      required this.facilityTollfree,
      required this.facilityWhatsapp,
      required this.facilityEmail,
      required this.facilityWebsite,
      required this.facilityPhone,
      required this.facilityContraception,
      required this.facilityPrep,
      required this.facilityAbortion,
      required this.facilityMenstrual,
      required this.facilitySTI,
      required this.facilityART,
      required this.facilityThumbnailUrl,
      required this.facilityLat,
      required this.facilityLon});

  factory TwysheFacility.fromJson(Map<String, dynamic> json) {
    return TwysheFacility(
      facilityId: json['facility_id'] as int,
      facilityName: json['facility_name'] as String,
      facilityAddress: json['facility_address'] as String,
      facilityTollfree: (json['facility_tollfree'] ?? '') as String,
      facilityWhatsapp: (json['facility_whatsapp'] ?? '') as String,
      facilityEmail: (json['facility_email'] ?? '') as String,
      facilityWebsite: (json['facility_website'] ?? '') as String,
      facilityPhone: (json['facility_phone'] ?? '') as String,
      facilityContraception:
          (json['facility_contraception'] == 1 ? 'Yes' : 'No'),
      facilityPrep: (json['facility_prep'] == 1 ? 'Yes' : 'No'),
      facilityAbortion: (json['facility_abortion'] == 1 ? 'Yes' : 'No'),
      facilityMenstrual: (json['facility_menstrual'] == 1 ? 'Yes' : 'No'),
      facilitySTI: (json['facility_sti'] == 1 ? 'Yes' : 'No'),
      facilityART: (json['facility_art'] == 1 ? 'Yes' : 'No'),
      facilityThumbnailUrl: json['facility_thumbnailUrl'] as String,
      facilityLat: json['facility_lat'] as double,
      facilityLon: json['facility_lon'] as double,
    );
  }
}
