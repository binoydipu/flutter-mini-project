// ============================================================
// add_symptom_screen.dart
// ============================================================
// Form for admins to add a new symptom.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../healthcare/models/speciality_model.dart';
import '../../healthcare/models/symptom_model.dart';
import '../../healthcare/services/healthcare_service.dart';
import '../services/admin_service.dart';

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<SpecialityModel> _specialities = [];
  int? _selectedSpecialityId;
  
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final specialities = await HealthcareService.getSpecialities();
    if (mounted) {
      setState(() {
        _specialities = specialities;
        _isFetching = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final symptom = SymptomModel(
      id: 0,
      name: _nameController.text.trim(),
    );

    final success = await AdminService.addSymptom(
      symptom: symptom,
      specialityId: _selectedSpecialityId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptom added successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add symptom')),
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
      appBar: AppBar(title: const Text('Add Symptom')),
      body: _isFetching 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Symptom Name (e.g. Headache)'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSpecialityId,
                      decoration: const InputDecoration(labelText: 'Related Speciality (Optional)'),
                      items: _specialities.map((spec) {
                        return DropdownMenuItem(
                          value: spec.id,
                          child: Text(spec.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSpecialityId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Symptom'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
