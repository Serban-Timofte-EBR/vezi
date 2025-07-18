import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const LocationCard({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              latitude != null && longitude != null
                  ? 'Locație: ($latitude, $longitude)'
                  : 'Locație neconfigurată',
            ),
          ],
        ),
      ),
    );
  }
}
