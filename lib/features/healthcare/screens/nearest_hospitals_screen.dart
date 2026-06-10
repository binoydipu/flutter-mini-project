// ============================================================
// hospitals_screen.dart
// ============================================================
// List view for displaying all available hospitals.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mini_project/core/helpers/utils.dart';
import 'package:mini_project/features/profile/services/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/hospital_model.dart';
import '../../healthcare/services/healthcare_service.dart';

class NearestHospitalsScreen extends StatefulWidget {
  const NearestHospitalsScreen({super.key});

  @override
  State<NearestHospitalsScreen> createState() => _NearestHospitalsScreenState();
}

class _NearestHospitalsScreenState extends State<NearestHospitalsScreen> {
  List<_NearbyHospital> _hospitals = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
    _adminCheck();
  }

  List<_NearbyHospital> findNearestHospitals({
    required List<HospitalModel> hospitals,
    required double userLat,
    required double userLng,
  }) {
    final distance = Distance();

    final result = hospitals
        .where((h) => h.latitude != null && h.longitude != null)
        .map((hospital) {
          final km = distance.as(
            LengthUnit.Kilometer,
            LatLng(userLat, userLng),
            LatLng(hospital.latitude!, hospital.longitude!),
          );

          return _NearbyHospital(hospital: hospital, distanceKm: km);
        })
        .toList();

    result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return result;
  }

  Future<void> _fetchHospitals() async {
    final hospitals = await HealthcareService.getHospitals();
    hospitals.removeWhere((h) => h.latitude == null || h.longitude == null);

    final position = await getCurrentLocation();

    final nearestHospitals = findNearestHospitals(
      hospitals: hospitals,
      userLat: position.latitude,
      userLng: position.longitude,
    );

    if (mounted) {
      setState(() {
        _hospitals = nearestHospitals;
        _isLoading = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Hospitals'),
        actions: [
          IconButton(
            onPressed: () async {
              // open google map with nearby hospitals
              final url =
                  'https://www.google.com/maps/search/hospitals+near+me';
              
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View on Map',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hospitals.isEmpty
          ? const Center(child: Text('No hospitals available at the moment.'))
          : RefreshIndicator(
              onRefresh: _fetchHospitals,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = _hospitals[index];
                  return _buildHospitalCard(hospital);
                },
              ),
            ),
    );
  }

  Widget _buildHospitalCard(_NearbyHospital nearbyHospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '/hospitals/${nearbyHospital.hospital.id}',
          extra: nearbyHospital.hospital,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital_rounded,
                    color: AppTheme.secondaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nearbyHospital.hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (nearbyHospital.hospital.city.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.location_city_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'City: ${nearbyHospital.hospital.city}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (nearbyHospital.hospital.address != null &&
                  nearbyHospital.hospital.address!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nearbyHospital.hospital.address!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (nearbyHospital.hospital.phone != null &&
                  nearbyHospital.hospital.phone!.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nearbyHospital.hospital.phone!,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),

              const SizedBox(height: 8),
              Text(
                'Distance: ${nearbyHospital.distanceKm.toStringAsFixed(2)} km',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyHospital {
  final HospitalModel hospital;
  final double distanceKm;

  _NearbyHospital({required this.hospital, required this.distanceKm});
}
