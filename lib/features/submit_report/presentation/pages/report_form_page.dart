import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/report_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  double? _latitude;
  double? _longitude;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ai refuzat permisiunea de locație')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permisiunea locației a fost blocată. Activeaz-o manual din setări.',
          ),
        ),
      );
      return;
    }

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
      appBar: AppBar(
        title: const Text('Trimite Sesizare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titlu'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Completează titlul'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descriere'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Completează descrierea'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Folosește locația'),
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Locație: ($_latitude, $_longitude)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Adaugă poză'),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages
                      .map(
                        (file) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
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
                                  content: Text('Te rog setează locația'),
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
    );
  }
}
