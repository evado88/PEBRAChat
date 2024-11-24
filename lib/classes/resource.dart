import 'dart:convert';

import 'package:twyshe/classes/resource_qa.dart';

class TwysheResource {
  final int resourceId;
  final String resourceName;
  final String resourceDescription;
  final String resourceUrl;
  final String resourceThumbnailUrl;
  final int resourceType;
  final String resourceContent;
  List<TwysheResourceQA> resourceQuestions;

  TwysheResource({
    required this.resourceId,
    required this.resourceName,
    required this.resourceDescription,
    required this.resourceUrl,
    required this.resourceThumbnailUrl,
    required this.resourceType,
    required this.resourceContent,
    required this.resourceQuestions,
  });

  factory TwysheResource.fromJson(Map<String, dynamic> json) {
    TwysheResource resource = TwysheResource(
      resourceId: json['resource_id'] as int,
      resourceName: json['resource_name'] as String,
      resourceDescription: json['resource_description'] as String,
      resourceUrl: json['resource_url'] as String,
      resourceThumbnailUrl: json['resource_thumbnailUrl'] as String,
      resourceType: json['resource_type'] as int,
      resourceContent: (json['resource_content'] ?? '') as String,
      resourceQuestions: [],
    );

    if (resource.resourceType == 2) {
      final parsed = jsonDecode(resource.resourceContent);

      resource.resourceQuestions = parsed
          .map<TwysheResourceQA>((res) => TwysheResourceQA.fromJson(res))
          .toList();
    }

    return resource;
  }
}
