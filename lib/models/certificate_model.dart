import 'package:sukonlanat_portfolio/models/award_categories.dart';
import 'package:sukonlanat_portfolio/models/competition_level.dart';

class CertificateModel {
  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    final awardMap = _nestedMap(
      map['award_category'] ?? map['award_categories'],
    );
    final levelMap = _nestedMap(
      map['competition_level'] ?? map['competition_levels'],
    );

    return CertificateModel(
      id: _string(map['id']),
      name: _string(map['name']),
      isFeatured: _bool(map['is_featured'] ?? map['isFeatured']),
      backgroundUrl: _string(map['background_url'] ?? map['backgroundUrl']),
      description: _string(map['description']),
      organizer: _string(map['organizer']),
      awardCategories: AwardCategories.fromMap({
        ...?awardMap,
        'id': map['award_category_id'] ?? awardMap?['id'],
        'name':
            _firstNonEmpty(map, ['award_category_name', 'category_name']) ??
            awardMap?['name'],
        'color': map['award_category_color'] ?? awardMap?['color'],
      }),
      competitionLevel: CompetitionLevel.fromMap({
        ...?levelMap,
        'id':
            map['competition_level_id'] ??
            map['competiton_level_id'] ??
            levelMap?['id'],
        'name':
            _firstNonEmpty(map, ['competition_level_name', 'level_name']) ??
            levelMap?['name'],
        'color': map['competition_level_color'] ?? levelMap?['color'],
      }),
      imagesUrl: _images(map['images_url'] ?? map['imagesUrl']),
      datePeriod: _string(map['date_period'] ?? map['datePeriod']),
      createdAt: DateTime.tryParse(_string(map['created_at'])),
    );
  }

  final String id;
  final String name;
  final bool isFeatured;
  final String backgroundUrl;
  final String description;
  final String organizer;
  final AwardCategories awardCategories;
  final CompetitionLevel competitionLevel;
  final List<String> imagesUrl;
  final String datePeriod;
  final DateTime? createdAt;

  CertificateModel({
    required this.id,
    required this.name,
    required this.isFeatured,
    required this.description,
    required this.organizer,
    required this.awardCategories,
    required this.competitionLevel,
    required this.backgroundUrl,
    required this.imagesUrl,
    required this.datePeriod,
    required this.createdAt,
  });

  static String _string(Object? value) => value?.toString() ?? '';

  static String? _firstNonEmpty(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = _string(map[key]);
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return _string(value).toLowerCase() == 'true';
  }

  static Map<String, dynamic>? _nestedMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<String> _images(Object? value) {
    if (value is List) {
      return value.map(_string).where((item) => item.isNotEmpty).toList();
    }
    final text = _string(value);
    return text.isEmpty ? const [] : [text];
  }
}
