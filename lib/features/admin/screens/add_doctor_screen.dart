// ============================================================
// add_doctor_screen.dart
// ============================================================
// Form for admins to add a new doctor.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/hospital_model.dart';
import '../../../core/models/speciality_model.dart';
import '../../healthcare/services/healthcare_service.dart';
import '../services/admin_service.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _designationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();

  List<HospitalModel> _hospitals = [];
  List<SpecialityModel> _specialities = [];

  int? _selectedHospitalId;
  int? _selectedSpecialityId;

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final hospitals = await HealthcareService.getHospitals();
    final specialities = await HealthcareService.getSpecialities();
    
    if (mounted) {
      setState(() {
        _hospitals = hospitals;
        _specialities = specialities;
        _isFetching = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final feeText = _feeController.text.trim();
    final expText = _experienceController.text.trim();

    final success = await AdminService.addDoctor(
      fullName: _nameController.text.trim(),
      qualification: _qualificationController.text.trim(),
      designation: _designationController.text.trim(),
      phone: _phoneController.text.trim(),
      experienceYears: expText.isNotEmpty ? int.tryParse(expText) : null,
      consultationFee: feeText.isNotEmpty ? double.tryParse(feeText) : null,
      hospitalId: _selectedHospitalId,
      specialityId: _selectedSpecialityId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add doctor')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Doctor')),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _qualificationController,
                      decoration: const InputDecoration(labelText: 'Qualification (e.g. MBBS, MD)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _designationController,
                      decoration: const InputDecoration(labelText: 'Designation (e.g. Senior Consultant)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _experienceController,
                            decoration: const InputDecoration(labelText: 'Experience (Years)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _feeController,
                            decoration: const InputDecoration(labelText: 'Consultation Fee'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Link to Hospital & Speciality',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedHospitalId,
                      decoration: const InputDecoration(labelText: 'Hospital (Optional)'),
                      items: _hospitals.map((h) {
                        return DropdownMenuItem(value: h.id, child: Text(h.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedHospitalId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSpecialityId,
                      decoration: const InputDecoration(labelText: 'Speciality (Optional)'),
                      items: _specialities.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSpecialityId = val),
                    ),
                    
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Doctor'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
