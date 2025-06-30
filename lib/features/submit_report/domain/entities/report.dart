import 'dart:io';

class Report {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final List<File>? images;

  Report({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.images,
  });
}
