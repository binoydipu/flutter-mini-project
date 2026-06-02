
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

  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorModel({
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
    this.createdAt,
    this.updatedAt,
  });


  DoctorModel copyWith({
    int? id,
    String? fullName,
    String? gender,
    String? profileImage,
    String? qualification,
    String? designation,
    int? experienceYears,
    String? bio,
    String? phone,
    String? email,
    double? consultationFee,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      qualification: qualification ?? this.qualification,
      designation: designation ?? this.designation,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      consultationFee: consultationFee ?? this.consultationFee,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] as int,
      fullName: map['full_name'] as String,
      gender: map['gender'] != null ? map['gender'] as String : null,
      profileImage: map['profile_image'] != null ? map['profile_image'] as String : null,
      qualification: map['qualification'] != null ? map['qualification'] as String : null,
      designation: map['designation'] != null ? map['designation'] as String : null,
      experienceYears: map['experience_years'] != null ? map['experience_years'] as int : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      consultationFee: map['consultation_fee'] != null ? map['consultation_fee'] as double : null,
      isActive: map['is_active'] as bool,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, fullName: $fullName, gender: $gender, profileImage: $profileImage, qualification: $qualification, designation: $designation, experienceYears: $experienceYears, bio: $bio, phone: $phone, email: $email, consultationFee: $consultationFee, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant DoctorModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.fullName == fullName &&
      other.gender == gender &&
      other.profileImage == profileImage &&
      other.qualification == qualification &&
      other.designation == designation &&
      other.experienceYears == experienceYears &&
      other.bio == bio &&
      other.phone == phone &&
      other.email == email &&
      other.consultationFee == consultationFee &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      fullName.hashCode ^
      gender.hashCode ^
      profileImage.hashCode ^
      qualification.hashCode ^
      designation.hashCode ^
      experienceYears.hashCode ^
      bio.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      consultationFee.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
