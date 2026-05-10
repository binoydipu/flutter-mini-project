// ============================================================
// doctor_model.dart
// ============================================================
// Represents a doctor from the "doctors" table in Supabase.
// ============================================================

class DoctorModel {
  final int id;
  final String fullName;
  final String? gender;
  final String? profileImage;
  final String? qualification;
  final String? designation;
  final int? experienceYears;
  final String? bio;
  final String? phone;
  final String? email;
  final double? consultationFee;
  final bool isActive;

  const DoctorModel({
    required this.id,
    required this.fullName,
    this.gender,
    this.profileImage,
    this.qualification,
    this.designation,
    this.experienceYears,
    this.bio,
    this.phone,
    this.email,
    this.consultationFee,
    this.isActive = true,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] as int,
      fullName: map['full_name'] as String? ?? 'Unknown Doctor',
      gender: map['gender'] as String?,
      profileImage: map['profile_image'] as String?,
      qualification: map['qualification'] as String?,
      designation: map['designation'] as String?,
      experienceYears: map['experience_years'] as int?,
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      // Handle numeric conversion from Postgres
      consultationFee: map['consultation_fee'] != null 
          ? (map['consultation_fee'] as num).toDouble() 
          : null,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'gender': gender,
      'profile_image': profileImage,
      'qualification': qualification,
      'designation': designation,
      'experience_years': experienceYears,
      'bio': bio,
      'phone': phone,
      'email': email,
      'consultation_fee': consultationFee,
      'is_active': isActive,
    };
  }
}
