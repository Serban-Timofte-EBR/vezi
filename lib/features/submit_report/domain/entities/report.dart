import 'dart:io';
import 'category.dart';

class Report {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final List<File>? images;
  final Category? category;

  Report({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.images,
    this.category,
  });
}
