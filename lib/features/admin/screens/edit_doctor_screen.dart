import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/doctor_model.dart';
import '../services/admin_service.dart';

class EditDoctorScreen extends StatefulWidget {
  final DoctorModel doctor;

  const EditDoctorScreen({super.key, required this.doctor});

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _designationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _phoneController;
  late final TextEditingController _feeController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor.fullName);
    _qualificationController = TextEditingController(
      text: widget.doctor.qualification ?? '',
    );
    _designationController = TextEditingController(
      text: widget.doctor.designation ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.doctor.experienceYears?.toString() ?? '',
    );
    _phoneController = TextEditingController(text: widget.doctor.phone ?? '');
    _feeController = TextEditingController(
      text: widget.doctor.consultationFee?.toString() ?? '',
    );
    _bioController = TextEditingController(text: widget.doctor.bio ?? '');
    _emailController = TextEditingController(text: widget.doctor.email ?? '');
    _selectedGender = widget.doctor.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final feeText = _feeController.text.trim();
    final expText = _experienceController.text.trim();

    final updatedDoctor = widget.doctor.copyWith(
      fullName: _nameController.text.trim(),
      qualification: _qualificationController.text.trim(),
      designation: _designationController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      gender: _selectedGender,
      experienceYears: expText.isNotEmpty ? int.tryParse(expText) : null,
      consultationFee: feeText.isNotEmpty ? double.tryParse(feeText) : null,
    );

    final success = await AdminService.updateDoctor(updatedDoctor);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor updated successfully')),
        );
        context.pop(true); // Return true to signal database reload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update doctor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Doctor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Qualification (e.g. MBBS, MD)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation (e.g. Senior Consultant)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Experience (Years)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _feeController,
                      decoration: const InputDecoration(
                        labelText: 'Consultation Fee (\$)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Biography / About',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
