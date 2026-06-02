// ============================================================
// hospitals_screen.dart
// ============================================================
// List view for displaying all available hospitals.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/hospital_model.dart';
import '../../healthcare/services/healthcare_service.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  List<HospitalModel> _hospitals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final hospitals = await HealthcareService.getHospitals();
    if (mounted) {
      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Hospitals'),
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

  Widget _buildHospitalCard(HospitalModel hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital_rounded, color: AppTheme.secondaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hospital.name,
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
            if (hospital.city.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_city_rounded, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text('City: ${hospital.city}', style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            const SizedBox(height: 4),
            if (hospital.address != null && hospital.address!.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(hospital.address!, style: const TextStyle(color: AppTheme.textSecondary)),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            if (hospital.phone != null && hospital.phone!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(hospital.phone!, style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
