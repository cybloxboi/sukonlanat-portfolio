import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/utils/image_url.dart';

class ProjectModel {
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: _string(map['id']),
      isFeatured: _bool(map['is_featured']),
      backgroundUrl: normalizeRemoteImageUrl(map['background_url']),
      name: _string(map['name']),
      description: _string(map['description']),
      githubUrl: _string(map['github_url']),
      projectUrl: _string(map['project_url']),
      imagesUrl: normalizeRemoteImageUrls(map['images_url']),
      date: DateTime.tryParse(_string(map['date'])),
      createdAt: DateTime.tryParse(_string(map['created_at'])),
      relatedCertificates: _relatedCertificates(map['related_certificates']),
    );
  }

  final String id;
  final bool isFeatured;
  final String backgroundUrl;
  final String name;
  final String description;
  final String githubUrl;
  final String projectUrl;
  final List<String> imagesUrl;
  final DateTime? date;
  final DateTime? createdAt;
  final List<CertificateModel> relatedCertificates;

  ProjectModel({
    required this.id,
    required this.isFeatured,
    required this.backgroundUrl,
    required this.name,
    required this.description,
    required this.githubUrl,
    required this.projectUrl,
    required this.imagesUrl,
    required this.date,
    required this.createdAt,
    this.relatedCertificates = const [],
  });

  static String _string(Object? value) => value?.toString() ?? '';

  static bool _bool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    return _string(value).toLowerCase() == 'true';
  }

  static List<CertificateModel> _relatedCertificates(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) {
          final nested = row['certificates'];
          return CertificateModel.fromMap(
            nested is Map
                ? Map<String, dynamic>.from(nested)
                : Map<String, dynamic>.from(row),
          );
        })
        .toList(growable: false);
  }
}
