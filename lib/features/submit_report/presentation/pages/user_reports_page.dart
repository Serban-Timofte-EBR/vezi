import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/report.dart';

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  Future<List<Report>> _fetchReports() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    const username = 'veziAdmin';
    const password = 'Mareparolagrea1234!';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await http.post(
      Uri.parse('https://api.openfocsani.eu/reports/all-by-user'),
      headers: {'Authorization': basicAuth, 'Content-Type': 'application/json'},
      body: jsonEncode({'userEmail': user.email}),
    );

    if (response.statusCode == 201) {
      final List data = json.decode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception('Eroare la încărcare: ${response.statusCode}');
    }
  }

  Widget _buildReportCard(Report report) {
    return GestureDetector(
      onTap: () {
        if (report.responseReceived) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Răspuns de la ${report.category?.institution ?? 'autoritate'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  report.responseContent ?? 'Fără conrținut.',
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Închide'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autoritatea nu a răspuns încă.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Categorie: ${report.category?.name ?? 'Necunoscut'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('Instituție: ${report.category?.institution ?? 'Necunoscut'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  report.responseReceived ? 'Răspuns primit' : 'În așteptare',
                  style: TextStyle(
                    color: report.responseReceived
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Istoric sesizări')),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Report>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Eroare: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Nu ai sesizări trimise.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildReportCard(reports[index]);
            },
          );
        },
      ),
    );
  }
}
