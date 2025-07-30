import 'dart:io';
import 'category.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String userId;
  final String userEmail;
  final List<File>? images;
  final Category? category;
  final bool responseReceived;
  final String? responseContent;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    this.images,
    this.category,
    this.responseReceived = false,
    this.responseContent,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      responseReceived: json['authorityResponse']?['received'] ?? false,
      responseContent: json['authorityResponse']?['content'],
    );
  }
}
