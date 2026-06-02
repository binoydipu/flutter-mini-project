// ============================================================
// add_speciality_screen.dart
// ============================================================
// Form for admins to add a new speciality.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/speciality_model.dart';
import '../services/admin_service.dart';

class AddSpecialityScreen extends StatefulWidget {
  const AddSpecialityScreen({super.key});

  @override
  State<AddSpecialityScreen> createState() => _AddSpecialityScreenState();
}

class _AddSpecialityScreenState extends State<AddSpecialityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final speciality = SpecialityModel(
      id: 0,
      name: _nameController.text.trim(),
    );

    final success = await AdminService.addSpeciality(speciality);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speciality added successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add speciality')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Speciality')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Speciality Name (e.g. Cardiology)'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Speciality'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
