import 'dart:io';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<File> images;
  final void Function(int) onRemove;

  const ImageGrid({super.key, required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        final img = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(img, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: const Icon(Icons.cancel, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
