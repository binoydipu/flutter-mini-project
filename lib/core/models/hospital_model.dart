
// ============================================================
// hospital_model.dart
// ============================================================
// Represents a hospital from the "hospitals" table in Supabase.
// ============================================================

class HospitalModel {
  final int id;
  final String name;
  final String? phone;
  final String? emergencyPhone;
  final String? email;
  final String? website;
  final String? address;
  final String city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool isActive;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HospitalModel({
    required this.id,
    required this.name,
    this.phone,
    this.emergencyPhone,
    this.email,
    this.website,
    this.address,
    required this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });


  HospitalModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? emergencyPhone,
    String? email,
    String? website,
    String? address,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'emergency_phone': emergencyPhone,
      'email': email,
      'website': website,
      'address': address,
      'city': city,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory HospitalModel.fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] != null ? map['phone'] as String : null,
      emergencyPhone: map['emergency_phone'] != null ? map['emergency_phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      website: map['website'] != null ? map['website'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      city: map['city'] as String,
      area: map['area'] != null ? map['area'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
      description: map['description'] != null ? map['description'] as String : null,
      isActive: map['is_active'] as bool,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  @override
  String toString() {
    return 'HospitalModel(id: $id, name: $name, phone: $phone, emergencyPhone: $emergencyPhone, email: $email, website: $website, address: $address, city: $city, area: $area, latitude: $latitude, longitude: $longitude, description: $description, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant HospitalModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.emergencyPhone == emergencyPhone &&
      other.email == email &&
      other.website == website &&
      other.address == address &&
      other.city == city &&
      other.area == area &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.description == description &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      emergencyPhone.hashCode ^
      email.hashCode ^
      website.hashCode ^
      address.hashCode ^
      city.hashCode ^
      area.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      description.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
