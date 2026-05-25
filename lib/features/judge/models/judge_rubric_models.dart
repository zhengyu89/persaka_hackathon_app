import 'package:cloud_firestore/cloud_firestore.dart';

class JudgeCriterion {
  const JudgeCriterion({
    required this.id,
    required this.name,
    required this.description,
    required this.weight,
    required this.maxScore,
    required this.active,
  });

  final String id;
  final String name;
  final String description;
  final double weight;
  final double maxScore;
  final bool active;

  factory JudgeCriterion.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return JudgeCriterion(
      id: doc.id,
      name: (data['name'] ?? 'Untitled Criterion').toString(),
      description: (data['description'] ?? '').toString(),
      weight: _numberValue(data['weight']),
      maxScore: _numberValue(data['maxScore'], fallback: 10),
      active: data['active'] != false,
    );
  }

  static double _numberValue(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse((value ?? '').toString()) ?? fallback;
  }
}
