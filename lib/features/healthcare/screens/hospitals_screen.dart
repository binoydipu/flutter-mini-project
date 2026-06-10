// ============================================================
// hospitals_screen.dart
// ============================================================
// List view for displaying all available hospitals.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/features/admin/services/admin_service.dart';
import 'package:mini_project/features/profile/services/profile_service.dart';
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
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
    _adminCheck();
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

  Future<void> _adminCheck() async {
    await ProfileService.isAdmin().then((isAdmin) {
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
        });
      }
    });
  }

  Future<void> _editHospital(HospitalModel hospital) async {
    final updated = await context.push<bool>(
      '/admin/edit-hospital',
      extra: hospital,
    );
    if (updated == true) {
      _fetchHospitals();
    }
  }

  Future<void> _handleDeleteHospital(int hospitalId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this hospital?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await AdminService.deleteHospital(hospitalId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hospital deleted successfully')),
          );
        }
        _fetchHospitals();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete hospital')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Hospitals')),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/hospitals/${hospital.id}', extra: hospital),
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
                    const Icon(
                      Icons.location_city_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'City: ${hospital.city}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (hospital.address != null && hospital.address!.isNotEmpty)
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
                        hospital.address!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (hospital.phone != null && hospital.phone!.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hospital.phone!,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (_isAdmin) // Show edit/delete buttons only for admins
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      iconSize: 20,
                      color: Colors.redAccent,
                      icon: Icon(Icons.delete_forever_rounded),
                      onPressed: () {
                        _handleDeleteHospital(hospital.id);
                      },
                    ),
                    IconButton(
                      iconSize: 20,
                      color: Colors.blueAccent,
                      icon: Icon(Icons.edit_rounded),
                      onPressed: () => _editHospital(hospital),
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
