import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
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
  final List<File> _selectedImages = [];

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ai refuzat permisiunea de locație')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Permisiunea locației a fost blocată permanent. Te rog activeaz-o din Settings!',
          ),
          action: SnackBarAction(
            label: 'Deschide',
            onPressed: () => AppSettings.openAppSettings(),
          ),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    ref.read(locationProvider.notifier).state = (
      latitude: position.latitude,
      longitude: position.longitude,
    );
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
    final location = ref.watch(locationProvider);

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
        ref.read(locationProvider.notifier).state = (
          latitude: null,
          longitude: null,
        );
        setState(() {
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
                  location.latitude != null && location.longitude != null
                      ? 'Locație: (${location.latitude}, ${location.longitude})'
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
                              if (location.latitude == null ||
                                  location.longitude == null) {
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
                                    latitude: location.latitude!,
                                    longitude: location.longitude!,
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
