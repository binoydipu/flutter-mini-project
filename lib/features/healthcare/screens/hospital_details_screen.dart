import 'package:flutter/material.dart';
import 'package:mini_project/core/models/hospital_model.dart';
import 'package:mini_project/features/profile/services/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailsScreen extends StatefulWidget {
  const HospitalDetailsScreen({super.key, required this.hospital});
  final HospitalModel hospital;

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  bool _isAdmin = false;

  Future<void> _adminCheck() async {
    await ProfileService.isAdmin().then((isAdmin) {
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
        });
      }
    });
  }

  @override
  initState() {
    super.initState();
    _adminCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Details'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                // Handle edit action
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital name and details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _itemCard('Name', widget.hospital.name),
                _itemCard('Address', widget.hospital.address ?? 'N/A'),
                _itemCard('Area', widget.hospital.area ?? 'N/A'),
                _itemCard('City', widget.hospital.city),
                _itemCard('Contact', widget.hospital.phone ?? 'N/A'),
                _itemCard(
                  'Emergency Contact',
                  widget.hospital.emergencyPhone ?? 'N/A',
                ),

                if (widget.hospital.latitude != null &&
                    widget.hospital.longitude != null)
                  OutlinedButton(
                    onPressed: () {
                      // Open location in maps
                      final lat = widget.hospital.latitude!;
                      final lng = widget.hospital.longitude!;
                      final url =
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                      // Use url_launcher to open the URL
                      launchUrl(Uri.parse(url));
                    },
                    child: const Text('View on Map'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
