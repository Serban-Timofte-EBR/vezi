import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/category.dart';

final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  try {
    print(
      '🔍 Attempting to fetch categories from: http://10.0.2.2:3000/category',
    );
    final response = await http
        .get(
          Uri.parse('http://10.0.2.2:3000/category'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Successfully parsed ${data.length} categories');
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      print('HTTP Error: ${response.statusCode} - ${response.body}');
      throw Exception('HTTP ${response.statusCode}: Failed to load categories');
    }
  } catch (e) {
    print('CATEGORY FETCH ERROR: $e');
    rethrow;
  }
});
