class ActivityModel {
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: _string(map['id']),
      name: _string(map['name']),
      isFeatured: _bool(map['is_featured'] ?? map['isFeatured']),
      backgroundUrl: _string(map['background_url'] ?? map['backgroundUrl']),
      description: _string(map['description']),
      organizer: _string(map['organizer']),
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
  final List<String> imagesUrl;
  final String datePeriod;
  final DateTime? createdAt;

  ActivityModel({
    required this.id,
    required this.name,
    required this.isFeatured,
    required this.description,
    required this.organizer,
    required this.backgroundUrl,
    required this.imagesUrl,
    required this.datePeriod,
    required this.createdAt,
  });

  static String _string(Object? value) => value?.toString() ?? '';

  static bool _bool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    return _string(value).toLowerCase() == 'true';
  }

  static List<String> _images(Object? value) {
    if (value is List) {
      return value.map(_string).where((item) => item.isNotEmpty).toList();
    }

    final text = _string(value);

    return text.isEmpty ? const [] : [text];
  }
}
