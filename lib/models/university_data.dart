import 'dart:ui';

class UniversityData {
  const UniversityData({
    required this.name,
    required this.shortName,
    required this.color,
    this.degreeName,
    this.projectName,
    this.introduceLink,
  });

  final String name;
  final String shortName;
  final Color color;
  final String? degreeName;
  final String? projectName;
  final String? introduceLink;
}
