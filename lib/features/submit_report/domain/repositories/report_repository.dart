import 'package:vezi/features/submit_report/domain/entities/report.dart';

abstract class IReportRepository {
  Future<void> submitReport(Report report);
}
