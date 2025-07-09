import 'dart:io';

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

final locationProvider = StateProvider<({double? latitude, double? longitude})>(
  (ref) {
    return (latitude: null, longitude: null);
  },
);

class SubmitReportController extends StateNotifier<AsyncValue<void>> {
  final SubmitReportUsecase usecase;

  SubmitReportController(this.usecase) : super(const AsyncValue.data(null));

  Future<void> submit({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    List<File>? images,
  }) async {
    state = const AsyncValue.loading();
    try {
      final report = Report(
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        images: images,
      );

      await usecase.execute(report);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
