class TwysheCountry {
  final int countryId;
  final String countryName;
  final String countryCode;

  const TwysheCountry({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
  });

  factory TwysheCountry.fromJson(Map<String, dynamic> json) {
    return TwysheCountry(
      countryId: json['country_id'] as int,
      countryName: json['country_name'] as String,
      countryCode: json['country_code'] as String,
    );
  }
}