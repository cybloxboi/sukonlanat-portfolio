import 'package:flutter/material.dart';

class CompetitionLevel {
  CompetitionLevel({
    required this.name,
    required this.color,
    this.id = otherId,
  });

  factory CompetitionLevel.fromId(
    String? id, {
    String? otherName,
    Color? otherColor,
  }) {
    final normalizedId = _normalizeId(id);
    final preset = presets[normalizedId];
    if (preset != null) return preset;
    return CompetitionLevel(
      id: normalizedId,
      name: otherName?.trim().isNotEmpty == true ? otherName!.trim() : 'อื่นๆ',
      color: otherColor ?? _colorFor(normalizedId),
    );
  }

  factory CompetitionLevel.fromMap(Map<String, dynamic>? map) {
    final value = map ?? const <String, dynamic>{};
    final id = _firstString(value, const [
      'id',
      'level_id',
      'competition_level_id',
      'competiton_level_id',
    ]);
    final name = _firstString(value, const [
      'name',
      'level_name',
      'competition_level_name',
    ]);
    return CompetitionLevel.fromId(
      id,
      otherName: name,
      otherColor: _parseColor(
        value['color'] ??
            value['color_hex'] ??
            value['competition_level_color'],
      ),
    );
  }

  static const String nationalId = 'national';
  static const String regionalId = 'regional';
  static const String provinceId = 'province';
  static const String schoolId = 'school';
  static const String otherId = 'other';

  static final Map<String, CompetitionLevel> presets = {
    nationalId: CompetitionLevel(
      id: nationalId,
      name: 'ระดับประเทศ',
      color: Color(0xFF2563EB),
    ),
    regionalId: CompetitionLevel(
      id: regionalId,
      name: 'ระดับภาค',
      color: Color(0xFF7C3AED),
    ),
    provinceId: CompetitionLevel(
      id: provinceId,
      name: 'ระดับจังหวัด',
      color: Color(0xFF059669),
    ),
    schoolId: CompetitionLevel(
      id: schoolId,
      name: 'ระดับโรงเรียน',
      color: Color(0xFFDC2626),
    ),
  };

  final String id;
  final String name;
  final Color color;

  static String _normalizeId(String? value) {
    final id = value?.trim().toLowerCase();
    if (id == null || id.isEmpty || id == 'อื่นๆ' || id == 'others') {
      return otherId;
    }
    return id;
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static Color? _parseColor(Object? value) {
    if (value is int) return Color(value);
    final hex = value?.toString().replaceFirst('#', '');
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.length == 6 ? 'ff$hex' : hex;
    final parsed = int.tryParse(normalized, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  static Color _colorFor(String id) {
    const colors = [
      Color(0xFF26A69A),
      Color(0xFFFF7043),
      Color(0xFF7E57C2),
      Color(0xFF29B6F6),
      Color(0xFF8D6E63),
      Color(0xFF9CCC65),
    ];
    return colors[id.codeUnits.fold(0, (sum, code) => sum + code) %
        colors.length];
  }
}
