// ============================================================
// doctors_screen.dart
// ============================================================
// List view for displaying all available doctors.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/doctor_model.dart';
import '../../healthcare/services/healthcare_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final doctors = await HealthcareService.getDoctors();
    if (mounted) {
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Doctors'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('No doctors available at the moment.'))
              : RefreshIndicator(
                  onRefresh: _fetchDoctors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      return _buildDoctorCard(doctor);
                    },
                  ),
                ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Placeholder
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                doctor.fullName.isNotEmpty ? doctor.fullName[0].toUpperCase() : 'D',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Doctor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (doctor.qualification != null && doctor.qualification!.isNotEmpty)
                    Text(
                      doctor.qualification!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (doctor.designation != null && doctor.designation!.isNotEmpty)
                    Text(
                      doctor.designation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (doctor.experienceYears != null)
                    Text(
                      'Experience: ${doctor.experienceYears} Years',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  if (doctor.consultationFee != null)
                    Text(
                      'Fee: \$${doctor.consultationFee!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
