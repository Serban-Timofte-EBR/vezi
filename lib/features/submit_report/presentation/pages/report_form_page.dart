import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/report_provider.dart';
import '../../domain/entities/category.dart';
import 'package:vezi/features/submit_report/presentation/providers/category_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';

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
  Category? _selectedCategory;

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

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
      if (_selectedImages.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poți adăuga maxim 3 poze!')),
        );
        return;
      }
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Set<Marker> _buildMarker() {
    if (_latitude == null || _longitude == null) return {};

    return {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: LatLng(_latitude!, _longitude!),
        draggable: true,
        onDragEnd: (LatLng newPos) {
          setState(() {
            _latitude = newPos.latitude;
            _longitude = newPos.longitude;
          });
        },
      ),
    };
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
          _selectedCategory = null;
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
              ref
                  .watch(categoryListProvider)
                  .when(
                    data: (categories) {
                      return DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Selectează categoria',
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (Category? selected) {
                          setState(() {
                            _selectedCategory = selected;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Selectează o categorie' : null,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) {
                      print('EROARE la categorie: $error');
                      return Text('Eroare la încărcarea categoriilor: $error');
                    },
                  ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: _latitude != null && _longitude != null
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_latitude!, _longitude!),
                          zoom: 16,
                        ),
                        onTap: (LatLng newPos) {
                          setState(() {
                            _latitude = newPos.latitude;
                            _longitude = newPos.longitude;
                          });
                        },
                        markers: _buildMarker(),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                      )
                    : const Center(child: CircularProgressIndicator()),
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
                                  category: _selectedCategory,
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
