import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import 'package:vezi/features/submit_report/domain/entities/report.dart';
import 'package:vezi/features/submit_report/domain/repositories/report_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailReportRepository implements IReportRepository {
  @override
  Future<void> submitReport(Report report) async {
    final uri = Uri.parse('https://api.openfocsani.eu/reports');

    const username = 'veziAdmin';
    const password = 'Mareparolagrea1234!';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Authorization': basicAuth});

    request.fields['title'] = report.title;
    request.fields['description'] = report.description;
    request.fields['latitude'] = report.latitude.toString();
    request.fields['longitude'] = report.longitude.toString();
    request.fields['type'] = 'citizen';
    request.fields['userId'] = user.uid;
    request.fields['userEmail'] = user.email ?? '';

    if (report.category != null && report.category!.id.isNotEmpty) {
      request.fields['category'] = report.category!.id;
    }

    if (report.images != null && report.images!.isNotEmpty) {
      for (final file in report.images!) {
        final length = await file.length();
        final stream = http.ByteStream(file.openRead());

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: p.basename(file.path),
          contentType: MediaType('image', _detectImageSubtype(file.path)),
        );

        request.files.add(multipartFile);
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Eroare la trimitere: ${response.statusCode} - $responseBody',
      );
    }
  }

  String _detectImageSubtype(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.png') return 'png';
    if (ext == '.jpg' || ext == '.jpeg') return 'jpeg';
    if (ext == '.gif') return 'gif';
    return 'jpeg';
  }
}
