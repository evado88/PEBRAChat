class TwysheColor {
  final int colorId;
  final String colorName;
  final String colorCode;

  const TwysheColor({
    required this.colorId,
    required this.colorName,
    required this.colorCode,
  });

  factory TwysheColor.fromJson(Map<String, dynamic> json) {
    return TwysheColor(
      colorId: json['color_id'] as int,
      colorName: json['color_name'] as String,
      colorCode: json['color_code'] as String,
    );
  }
}