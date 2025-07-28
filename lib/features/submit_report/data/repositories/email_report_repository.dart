import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vezi/features/submit_report/domain/entities/report.dart';
import 'package:vezi/features/submit_report/domain/repositories/report_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailReportRepository implements IReportRepository {
  @override
  Future<void> submitReport(Report report) async {
    final url = Uri.parse('http://10.0.2.2:3000/reports');

    const username = 'veziAdmin';
    const password = 'Mareparolagrea1234!';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},
      body: jsonEncode({
        'title': report.title,
        'description': report.description,
        'latitude': report.latitude,
        'longitude': report.longitude,
        'type': 'citizen',
        'userId': user.uid,
        'userEmail': user.email,
        'category': report.category?.id,
        'images': [], // momentan lista goală, va fi completată mai târziu
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Eroare la trimitere: ${response.statusCode}');
    }
  }
}
