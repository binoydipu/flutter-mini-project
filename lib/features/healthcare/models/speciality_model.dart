// ============================================================
// speciality_model.dart
// ============================================================
// Represents a medical speciality from the "specialities" table.
// ============================================================

class SpecialityModel {
  final int id;
  final String name;
  final String? icon;

  const SpecialityModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory SpecialityModel.fromMap(Map<String, dynamic> map) {
    return SpecialityModel(
      id: map['id'] as int,
      name: map['name'] as String? ?? 'Unknown Speciality',
      icon: map['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}
