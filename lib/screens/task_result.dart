class TwysheTaskResult {
  final bool succeeded;
  final String message;
  List<dynamic> items;


   TwysheTaskResult({
    required this.succeeded,
    required this.message,
    required this.items,
  });

  factory TwysheTaskResult.fromJson(Map<String, dynamic> json) {
    return TwysheTaskResult(
      succeeded: json['succeeded'] as bool,
      message: json['message'] ?? '',
      items: []
    );
  }
}