// ============================================================
// edit_hospital_screen.dart
// ============================================================
// Form for admins to update an existing hospital's details.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/hospital_model.dart';
import '../services/admin_service.dart';

class EditHospitalScreen extends StatefulWidget {
  final HospitalModel hospital;

  const EditHospitalScreen({super.key, required this.hospital});

  @override
  State<EditHospitalScreen> createState() => _EditHospitalScreenState();
}

class _EditHospitalScreenState extends State<EditHospitalScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _areaController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _descriptionController;
  late bool _isActive;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final h = widget.hospital;
    _nameController        = TextEditingController(text: h.name);
    _phoneController       = TextEditingController(text: h.phone ?? '');
    _emergencyPhoneController = TextEditingController(text: h.emergencyPhone ?? '');
    _emailController       = TextEditingController(text: h.email ?? '');
    _websiteController     = TextEditingController(text: h.website ?? '');
    _addressController     = TextEditingController(text: h.address ?? '');
    _cityController        = TextEditingController(text: h.city);
    _areaController        = TextEditingController(text: h.area ?? '');
    _latitudeController    = TextEditingController(text: h.latitude?.toString() ?? '');
    _longitudeController   = TextEditingController(text: h.longitude?.toString() ?? '');
    _descriptionController = TextEditingController(text: h.description ?? '');
    _isActive              = h.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyPhoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updated = widget.hospital.copyWith(
      name:           _nameController.text.trim(),
      phone:          _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      email:          _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      website:        _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      address:        _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      city:           _cityController.text.trim(),
      area:           _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
      latitude:       double.tryParse(_latitudeController.text.trim()),
      longitude:      double.tryParse(_longitudeController.text.trim()),
      description:    _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isActive:       _isActive,
    );

    final success = await AdminService.updateHospital(updated);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital updated successfully')),
        );
        context.pop(true); // signal caller to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update hospital')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Hospital')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Basic info ──────────────────────────────────
              _sectionLabel('Basic Information'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hospital Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ── Location ────────────────────────────────────
              _sectionLabel('Location'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area'),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Full Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (double.tryParse(v.trim()) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (double.tryParse(v.trim()) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Contact ─────────────────────────────────────
              _sectionLabel('Contact Information'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(labelText: 'Emergency Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // ── Status ──────────────────────────────────────
              _sectionLabel('Status'),
              const SizedBox(height: 8),

              Card(
                child: SwitchListTile(
                  title: const Text('Active'),
                  subtitle: Text(_isActive ? 'Hospital is visible to users' : 'Hospital is hidden from users'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}
