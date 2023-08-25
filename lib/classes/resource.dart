class TwysheResource {
  final int resourceId;
  final String resourceName;
  final String resourceDescription;
  final String resourceUrl;
  final String resourceThumbnailUrl;

  const TwysheResource({
    required this.resourceId,
    required this.resourceName,
    required this.resourceDescription,
    required this.resourceUrl,
    required this.resourceThumbnailUrl,
  });

  factory TwysheResource.fromJson(Map<String, dynamic> json) {
    return TwysheResource(
      resourceId: json['resource_id'] as int,
      resourceName: json['resource_name'] as String,
      resourceDescription: json['resource_description'] as String,
      resourceUrl: json['resource_url'] as String,
      resourceThumbnailUrl: json['resource_thumbnailUrl'] as String,
    );
  }
}