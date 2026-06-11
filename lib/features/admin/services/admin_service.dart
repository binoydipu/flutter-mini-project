// ============================================================
// admin_service.dart
// ============================================================
// Handles inserting data into the database from the Admin panel.
// ============================================================

import 'package:flutter/material.dart';
import 'package:mini_project/main.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/hospital_model.dart';

class AdminService {
  /// Adds a new doctor. Optionally links to a hospital and/or speciality.
  static Future<bool> addDoctor({
    required String fullName,
    required String qualification,
    required String designation,
    required String phone,
    int? experienceYears,
    double? consultationFee,
    int? hospitalId,
    int? specialityId,
    String? availableDays,
    String? availableTime,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final data = {
        'full_name': fullName,
        'qualification': qualification,
        'designation': designation,
        'phone': phone,
        'experience_years': experienceYears,
        'consultation_fee': consultationFee,
        'created_by': userId,
      };

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
          'available_days': availableDays,
          'available_time': availableTime,
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
      debugPrint('Error adding doctor: $e');
      return false;
    }
  }

  /// Adds a new hospital
  static Future<bool> addHospital({
    required String name,
    required String city,
    required String area,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final data = {
        'name': name,
        'city': city,
        'area': area,
        'address': address,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
        'created_by': userId,
      };

      await supabase.from('hospitals').insert(data);
      return true;
    } catch (e) {
      debugPrint('Error adding hospital: $e');
      return false;
    }
  }

  static Future<bool> deleteHospital(int hospitalId) async {
    try {
      await supabase.from('hospitals').delete().eq('id', hospitalId);
      return true;
    } catch (e) {
      debugPrint('Error deleting hospital: $e');
      return false;
    }
  }

  /// Adds a new speciality
  static Future<bool> addSpeciality({required String name}) async {
    try {
      await supabase.from('specialities').insert({'name': name});
      return true;
    } catch (e) {
      debugPrint('Error adding speciality: $e');
      return false;
    }
  }

  /// Adds a new symptom. Optionally links to a speciality.
  static Future<bool> addSymptom({
    required String name,
    int? specialityId,
  }) async {
    try {
      // 1. Insert Symptom
      final symptomResponse = await supabase
          .from('symptoms')
          .insert({'name': name})
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
      debugPrint('Error adding symptom: $e');
      return false;
    }
  }

  /// Updates doctor profile details
  static Future<bool> updateDoctor(DoctorModel doctor) async {
    try {
      final data = doctor.toMap();
      data.remove('created_at'); // Do not overwrite created_at
      data['updated_at'] = DateTime.now().toIso8601String();

      await supabase.from('doctors').update(data).eq('id', doctor.id);
      return true;
    } catch (e) {
      debugPrint('Error updating doctor: $e');
      return false;
    }
  }

  /// Links a new speciality to a doctor
  static Future<bool> addDoctorSpeciality({
    required int doctorId,
    required int specialityId,
  }) async {
    try {
      await supabase.from('doctor_specialities').insert({
        'doctor_id': doctorId,
        'speciality_id': specialityId,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding doctor speciality: $e');
      return false;
    }
  }

  /// Updates hospital details
  static Future<bool> updateHospital(HospitalModel hospital) async {
    try {
      final data = hospital.toMap();
      data.remove('created_at'); // Do not overwrite created_at
      data['updated_at'] = DateTime.now().toIso8601String();

      await supabase.from('hospitals').update(data).eq('id', hospital.id);
      return true;
    } catch (e) {
      debugPrint('Error updating hospital: $e');
      return false;
    }
  }
}
