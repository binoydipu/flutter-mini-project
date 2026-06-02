
// ============================================================
// speciality_model.dart
// ============================================================
// Represents a medical speciality from the "specialities" table.
// ============================================================

class SpecialityModel {
  final int id;
  final String name;
  final String? icon;

  SpecialityModel({
    required this.id,
    required this.name,
    this.icon,
  });


  SpecialityModel copyWith({
    int? id,
    String? name,
    String? icon,
  }) {
    return SpecialityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory SpecialityModel.fromMap(Map<String, dynamic> map) {
    return SpecialityModel(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] != null ? map['icon'] as String : null,
    );
  }

  @override
  String toString() => 'SpecialityModel(id: $id, name: $name, icon: $icon)';

  @override
  bool operator ==(covariant SpecialityModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.icon == icon;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.hashCode;
}
