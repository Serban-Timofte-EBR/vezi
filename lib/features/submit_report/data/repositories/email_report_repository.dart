import 'package:vezi/features/submit_report/domain/entities/report.dart';
import 'package:vezi/features/submit_report/domain/repositories/report_repository.dart';

class EmailReportRepository implements IReportRepository {
  @override
  Future<void> submitReport(Report report) {
    // TODO: implement submitReport - SMTP, Firebase, etc.
    throw UnimplementedError();
  }
}
