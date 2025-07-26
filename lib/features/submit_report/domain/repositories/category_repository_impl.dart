import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final String baseUrl;

  CategoryRepositoryImpl({required this.baseUrl});

  @override
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/category'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
