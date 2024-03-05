class TwysheTaskResult {
  final bool succeeded;
  final String message;
  List<dynamic> items;
  final dynamic data;

   TwysheTaskResult({
    required this.succeeded,
    required this.message,
    required this.items,
    this.data
  });

  factory TwysheTaskResult.fromJson(Map<String, dynamic> json) {
    return TwysheTaskResult(
      succeeded: json['succeeded'] as bool,
      message: json['message'] ?? '',
      items: [],
    );
  }
}