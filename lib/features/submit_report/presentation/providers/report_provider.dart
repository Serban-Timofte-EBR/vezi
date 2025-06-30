import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/submit_report_usecase.dart';
import '../../data/repositories/email_report_repository.dart';

final submitReportUsecaseProvider = Provider<SubmitReportUsecase>((ref) {
  return SubmitReportUsecase(EmailReportRepository());
});

final submitReportControllerProvider =
    StateNotifierProvider<SubmitReportController, AsyncValue<void>>((ref) {
      final usecase = ref.read(submitReportUsecaseProvider);
      return SubmitReportController(usecase);
    });

class SubmitReportController extends StateNotifier<AsyncValue<void>> {
  final SubmitReportUsecase usecase;

  SubmitReportController(this.usecase) : super(const AsyncValue.data(null));

  Future<void> submit(String title, String description) async {
    state = const AsyncValue.loading();
    try {
      await usecase.execute(Report(title: title, description: description));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
