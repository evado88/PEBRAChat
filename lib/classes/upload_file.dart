class TwysheUploadFile {

  final String name;
  final String? mimeType;
  final String uri;
  final int size;

   TwysheUploadFile({
    required this.name,
    required this.uri,
    required this.size,
    required this.mimeType
  });

}