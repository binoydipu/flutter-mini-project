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

  const HospitalModel({
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
  });

  factory HospitalModel.fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      id: map['id'] as int,
      name: map['name'] as String? ?? 'Unknown Hospital',
      phone: map['phone'] as String?,
      emergencyPhone: map['emergency_phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String? ?? 'Unknown City',
      area: map['area'] as String?,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
