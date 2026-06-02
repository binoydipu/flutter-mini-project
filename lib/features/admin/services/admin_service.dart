// ============================================================
// admin_service.dart
// ============================================================
// Handles inserting data into the database from the Admin panel.
// ============================================================

import 'package:mini_project/main.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/hospital_model.dart';
import '../../../core/models/speciality_model.dart';
import '../../../core/models/symptom_model.dart';

class AdminService {

  /// Adds a new doctor. Optionally links to a hospital and/or speciality.
  static Future<bool> addDoctor({
    required DoctorModel doctor,
    int? hospitalId,
    int? specialityId,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final data = doctor.toMap();
      data['created_by'] = userId;

      // 1. Insert Doctor
      final doctorResponse = await supabase
          .from('doctors')
          .insert(data)
          .select('id')
          .single();

      final newDoctorId = doctorResponse['id'] as int;

      // 2. Link Hospital if provided
      if (hospitalId != null) {
        await supabase.from('doctor_hospitals').insert({
          'doctor_id': newDoctorId,
          'hospital_id': hospitalId,
        });
      }

      // 3. Link Speciality if provided
      if (specialityId != null) {
        await supabase.from('doctor_specialities').insert({
          'doctor_id': newDoctorId,
          'speciality_id': specialityId,
        });
      }

      return true;
    } catch (e) {
      print('Error adding doctor: $e');
      return false;
    }
  }

  /// Adds a new hospital
  static Future<bool> addHospital(HospitalModel hospital) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final data = hospital.toMap();
      data['created_by'] = userId;

      await supabase.from('hospitals').insert(data);
      return true;
    } catch (e) {
      print('Error adding hospital: $e');
      return false;
    }
  }

  /// Adds a new speciality
  static Future<bool> addSpeciality(SpecialityModel speciality) async {
    try {
      await supabase.from('specialities').insert(speciality.toMap());
      return true;
    } catch (e) {
      print('Error adding speciality: $e');
      return false;
    }
  }

  /// Adds a new symptom. Optionally links to a speciality.
  static Future<bool> addSymptom({
    required SymptomModel symptom,
    int? specialityId,
  }) async {
    try {
      // 1. Insert Symptom
      final symptomResponse = await supabase
          .from('symptoms')
          .insert(symptom.toMap())
          .select('id')
          .single();

      final newSymptomId = symptomResponse['id'] as int;

      // 2. Link Speciality if provided
      if (specialityId != null) {
        await supabase.from('symptom_specialities').insert({
          'symptom_id': newSymptomId,
          'speciality_id': specialityId,
          'priority': 1,
        });
      }

      return true;
    } catch (e) {
      print('Error adding symptom: $e');
      return false;
    }
  }
}
