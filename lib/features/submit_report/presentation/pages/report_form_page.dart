import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/report_provider.dart';

class ReportFormPage extends ConsumerStatefulWidget {
  const ReportFormPage({super.key});

  @override
  ConsumerState<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends ConsumerState<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  double? _latitude;
  double? _longitude;
  final List<File> _selectedImages = [];

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      if (_selectedImages.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poți adăuga maxim 5 poze!')),
        );
        return;
      }
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        setState(() {
          _latitude = null;
          _longitude = null;
          _selectedImages.clear();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Trimite Sesizare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: const Text('Folosește Locația Curentă'),
                ),
                Text(
                  _latitude != null && _longitude != null
                      ? 'Locație: ($_latitude, $_longitude)'
                      : 'Locație neconfigurată',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Adaugă Poză'),
                ),
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((img) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            img,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImages.remove(img);
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (_latitude == null || _longitude == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Te rog setează locația!'),
                                  ),
                                );
                                return;
                              }
                              ref
                                  .read(submitReportControllerProvider.notifier)
                                  .submit(
                                    title: _titleController.text.trim(),
                                    description: _descController.text.trim(),
                                    latitude: _latitude!,
                                    longitude: _longitude!,
                                    images: _selectedImages.isNotEmpty
                                        ? _selectedImages
                                        : null,
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
      ),
    );
  }
}
