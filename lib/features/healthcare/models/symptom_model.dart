// ============================================================
// symptom_model.dart
// ============================================================
// Represents a symptom from the "symptoms" table.
// ============================================================

class SymptomModel {
  final int id;
  final String name;

  const SymptomModel({
    required this.id,
    required this.name,
  });

  factory SymptomModel.fromMap(Map<String, dynamic> map) {
    return SymptomModel(
      id: map['id'] as int,
      name: map['name'] as String? ?? 'Unknown Symptom',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
