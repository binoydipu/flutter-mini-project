
// ============================================================
// symptom_model.dart
// ============================================================
// Represents a symptom from the "symptoms" table.
// ============================================================

class SymptomModel {
  final int id;
  final String name;

  SymptomModel({
    required this.id,
    required this.name,
  });


  SymptomModel copyWith({
    int? id,
    String? name,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory SymptomModel.fromMap(Map<String, dynamic> map) {
    return SymptomModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  @override
  String toString() => 'SymptomModel(id: $id, name: $name)';

  @override
  bool operator ==(covariant SymptomModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
