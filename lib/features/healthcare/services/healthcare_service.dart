// ============================================================
// healthcare_service.dart
// ============================================================
// Fetches data for the healthcare application.
// ============================================================

import 'package:mini_project/main.dart' show supabase;
import '../models/doctor_model.dart';
import '../models/hospital_model.dart';
import '../models/speciality_model.dart';
import '../models/symptom_model.dart';

class HealthcareService {
  /// Fetches all active doctors
  static Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await supabase
          .from('doctors')
          .select()
          .eq('is_active', true)
          .order('full_name');

      return (response as List).map((e) => DoctorModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  /// Fetches all active hospitals
  static Future<List<HospitalModel>> getHospitals() async {
    try {
      final response = await supabase
          .from('hospitals')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List).map((e) => HospitalModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

  /// Fetches all specialities
  static Future<List<SpecialityModel>> getSpecialities() async {
    try {
      final response = await supabase
          .from('specialities')
          .select()
          .order('name');

      return (response as List).map((e) => SpecialityModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching specialities: $e');
      return [];
    }
  }

  /// Fetches all symptoms
  static Future<List<SymptomModel>> getSymptoms() async {
    try {
      final response = await supabase
          .from('symptoms')
          .select()
          .order('name');

      return (response as List).map((e) => SymptomModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching symptoms: $e');
      return [];
    }
  }
}
