import 'package:vezi/features/submit_report/domain/entities/report.dart';
import 'package:vezi/features/submit_report/domain/repositories/report_repository.dart';

class SubmitReportUsecase {
  final IReportRepository repository;

  SubmitReportUsecase(this.repository);

  Future<void> execute(Report report) async {
    await repository.submitReport(report);
  }
}
