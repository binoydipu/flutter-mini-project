// ============================================================
// healthcare_service.dart
// ============================================================
// Fetches data for the healthcare application.
// ============================================================

import 'package:flutter/material.dart';
import 'package:mini_project/main.dart' show supabase;
import '../../../core/models/doctor_model.dart';
import '../../../core/models/hospital_model.dart';
import '../../../core/models/speciality_model.dart';
import '../../../core/models/symptom_model.dart';

class HealthcareService {
  /// Fetches all active doctors with optional filters
  static Future<List<DoctorModel>> getDoctors({
    String? searchQuery,
    int? specialityId,
    String? area,
    int? hospitalId,
    int? minExperience,
    double? maxFee,
  }) async {
    try {
      // Fetch matching speciality IDs from symptoms if search query is provided
      List<int> symptomSpecialityIds = [];
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        try {
          final symptomResponse = await supabase
              .from('symptoms')
              .select('id, name, symptom_specialities(speciality_id)')
              .ilike('name', '%$term%');

          final symptomList = symptomResponse as List;
          for (var item in symptomList) {
            final symSpecs = item['symptom_specialities'];
            if (symSpecs is List) {
              for (var symSpec in symSpecs) {
                final specId = symSpec['speciality_id'];
                if (specId != null) {
                  symptomSpecialityIds.add(specId as int);
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error searching symptoms: $e');
        }
      }

      // Query doctors with their specialities and hospitals
      final response = await supabase
          .from('doctors')
          .select('''
            *,
            doctor_specialities(
              speciality_id,
              specialities(name)
            ),
            doctor_hospitals(
              hospital_id,
              hospitals(name, area, city)
            )
          ''')
          .eq('is_active', true)
          .order('full_name');

      final responseList = response as List;
      List<DoctorModel> doctors = responseList
          .map((e) => DoctorModel.fromMap(e as Map<String, dynamic>))
          .toList();

      // Apply in-memory filters
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        doctors = doctors.where((doc) {
          // Check name
          if (doc.fullName.toLowerCase().contains(term)) return true;
          // Check designation / qualification
          if (doc.designation?.toLowerCase().contains(term) ?? false) {
            return true;
          }
          if (doc.qualification?.toLowerCase().contains(term) ?? false) {
            return true;
          }

          // Check if any associated speciality name matches or ID matches symptom specialities
          final matchingDocs = responseList.where(
            (element) => element['id'] == doc.id,
          );
          if (matchingDocs.isNotEmpty) {
            final rawDoc = matchingDocs.first as Map<String, dynamic>;
            final docSpecs = rawDoc['doctor_specialities'] as List?;
            if (docSpecs != null) {
              for (var ds in docSpecs) {
                final specId = ds['speciality_id'] as int?;
                if (specId != null && symptomSpecialityIds.contains(specId)) {
                  return true;
                }
                final specName = ds['specialities']?['name'] as String?;
                if (specName != null && specName.toLowerCase().contains(term)) {
                  return true;
                }
              }
            }
          }
          return false;
        }).toList();
      }

      if (specialityId != null) {
        doctors = doctors.where((doc) {
          final matchingDocs = responseList.where(
            (element) => element['id'] == doc.id,
          );
          if (matchingDocs.isNotEmpty) {
            final rawDoc = matchingDocs.first as Map<String, dynamic>;
            final docSpecs = rawDoc['doctor_specialities'] as List?;
            if (docSpecs != null) {
              return docSpecs.any((ds) => ds['speciality_id'] == specialityId);
            }
          }
          return false;
        }).toList();
      }

      if (area != null && area.isNotEmpty) {
        doctors = doctors.where((doc) {
          final matchingDocs = responseList.where(
            (element) => element['id'] == doc.id,
          );
          if (matchingDocs.isNotEmpty) {
            final rawDoc = matchingDocs.first as Map<String, dynamic>;
            final docHops = rawDoc['doctor_hospitals'] as List?;
            if (docHops != null) {
              return docHops.any(
                (dh) =>
                    dh['hospitals']?['area']?.toString().trim().toLowerCase() ==
                    area.trim().toLowerCase(),
              );
            }
          }
          return false;
        }).toList();
      }

      if (hospitalId != null) {
        doctors = doctors.where((doc) {
          final matchingDocs = responseList.where(
            (element) => element['id'] == doc.id,
          );
          if (matchingDocs.isNotEmpty) {
            final rawDoc = matchingDocs.first as Map<String, dynamic>;
            final docHops = rawDoc['doctor_hospitals'] as List?;
            if (docHops != null) {
              return docHops.any((dh) => dh['hospital_id'] == hospitalId);
            }
          }
          return false;
        }).toList();
      }

      if (minExperience != null) {
        doctors = doctors
            .where((doc) => (doc.experienceYears ?? 0) >= minExperience)
            .toList();
      }
      
      if (maxFee != null) {
        doctors = doctors
            .where((doc) => (doc.consultationFee ?? 0.0) <= maxFee)
            .toList();
      }

      return doctors;
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getDoctorById(int doctorId) async {
    try {
      final response = await supabase
          .from('doctors')
          .select('''
            doctor_specialities(specialities(id, name, icon)),
            doctor_hospitals(
              hospital_id,
              chamber_name,
              room_no,
              appointment_phone,
              available_days,
              available_time,
              hospitals(name, area, city, address, phone)
            )
          ''')
          .eq('id', doctorId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching doctor by ID: $e');
      return null;
    }
  }

  /// Fetches unique areas from all active hospitals
  static Future<List<String>> getUniqueAreas() async {
    try {
      final response = await supabase
          .from('hospitals')
          .select('area')
          .eq('is_active', true);

      final responseList = response as List;
      final areas = responseList
          .map((e) => e['area'] as String?)
          .where((area) => area != null && area.trim().isNotEmpty)
          .map((area) => area!.trim())
          .toSet()
          .toList();
      areas.sort();
      return areas;
    } catch (e) {
      debugPrint('Error fetching unique areas: $e');
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
      debugPrint('Error fetching hospitals: $e');
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
      debugPrint('Error fetching specialities: $e');
      return [];
    }
  }

  /// Fetches all symptoms
  static Future<List<SymptomModel>> getSymptoms() async {
    try {
      final response = await supabase.from('symptoms').select().order('name');

      return (response as List).map((e) => SymptomModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching symptoms: $e');
      return [];
    }
  }
}
