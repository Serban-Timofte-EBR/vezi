import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/submit_report/presentation/pages/report_form_page.dart';

void main() {
  runApp(const ProviderScope(child: CivicAlertApp()));
}

class CivicAlertApp extends StatelessWidget {
  const CivicAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Alert',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: ReportFormPage(),
    );
  }
}
