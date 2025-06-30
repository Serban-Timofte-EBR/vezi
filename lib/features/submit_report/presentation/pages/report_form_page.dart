import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_provider.dart';

class ReportFormPage extends ConsumerWidget {
  ReportFormPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(submitReportControllerProvider);

    ref.listen(submitReportControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Eroare: ${next.error}')));
      }
      if (!next.isLoading && next.hasValue) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sesizare trimisă!')));
        _titleController.clear();
        _descController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Trimite Sesizare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titlu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Completează titlul'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descriere',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Completează descrierea'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(submitReportControllerProvider.notifier)
                                .submit(
                                  _titleController.text.trim(),
                                  _descController.text.trim(),
                                );
                          }
                        },
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Trimite Sesizare'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
