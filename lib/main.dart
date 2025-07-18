import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vezi/core/theme/app_theme.dart';
import 'features/submit_report/presentation/pages/report_form_page.dart';

void main() {
  runApp(const ProviderScope(child: CivicAlertApp()));
}

class CivicAlertApp extends StatelessWidget {
  const CivicAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vezi Civic Alert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ReportFormPage(),
    );
  }
}
