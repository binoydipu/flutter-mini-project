// ============================================================
// doctors_screen.dart
// ============================================================
// List view for displaying all available doctors.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/doctor_model.dart';
import '../../healthcare/services/healthcare_service.dart';
import '../../profile/services/profile_service.dart';
import '../../admin/services/admin_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _checkAdmin();
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

  Future<void> _checkAdmin() async {
    final isAdmin = await ProfileService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  Future<void> _editDoctor(DoctorModel doctor) async {
    final updated = await context.push<bool>(
      '/admin/edit-doctor',
      extra: doctor,
    );
    if (updated == true) {
      _fetchDoctors();
    }
  }

  Future<void> _addSpeciality(DoctorModel doctor) async {
    // Show dialog to select and assign a speciality to the doctor
    final specialities = await HealthcareService.getSpecialities();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        int? selectedSpecId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Assign Speciality to ${doctor.fullName}'),
              content: specialities.isEmpty
                  ? const Text(
                      'No specialities available to link. Please create one in admin panel first.',
                    )
                  : DropdownButtonFormField<int>(
                      value: selectedSpecId,
                      decoration: const InputDecoration(
                        labelText: 'Choose Speciality',
                      ),
                      items: specialities.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedSpecId = val),
                    ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedSpecId == null
                      ? null
                      : () async {
                          final success =
                              await AdminService.addDoctorSpeciality(
                                doctorId: doctor.id,
                                specialityId: selectedSpecId!,
                              );
                          if (context.mounted) {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Speciality added to doctor successfully'
                                      : 'Failed to assign speciality',
                                ),
                              ),
                            );
                            _fetchDoctors();
                          }
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Doctors')),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/doctors/${doctor.id}', extra: doctor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Placeholder
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage:
                    doctor.profileImage != null &&
                        doctor.profileImage!.isNotEmpty
                    ? NetworkImage(doctor.profileImage!)
                    : null,
                child:
                    doctor.profileImage == null || doctor.profileImage!.isEmpty
                    ? Text(
                        doctor.fullName.isNotEmpty
                            ? doctor.fullName[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      )
                    : null,
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
                    if (doctor.qualification != null &&
                        doctor.qualification!.isNotEmpty)
                      Text(
                        doctor.qualification!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (doctor.designation != null &&
                        doctor.designation!.isNotEmpty)
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    if (doctor.consultationFee != null)
                      Text(
                        'Fee: \$${doctor.consultationFee!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              if (_isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editDoctor(doctor);
                    } else if (value == 'speciality') {
                      _addSpeciality(doctor);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text('Edit Doctor'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'speciality',
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text('Add Speciality'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
