import 'package:flutter/material.dart';

class AwardCategories {
  AwardCategories({required this.name, required this.color, this.id = otherId});

  factory AwardCategories.fromId(
    String? id, {
    String? otherName,
    Color? otherColor,
  }) {
    final normalizedId = _normalizeId(id);
    final preset = presets[normalizedId];
    if (preset != null) return preset;
    return AwardCategories(
      id: normalizedId,
      name: otherName?.trim().isNotEmpty == true ? otherName!.trim() : 'อื่นๆ',
      color: otherColor ?? _colorFor(normalizedId),
    );
  }

  factory AwardCategories.fromMap(Map<String, dynamic>? map) {
    final value = map ?? const <String, dynamic>{};
    final id = _firstString(value, const [
      'id',
      'category_id',
      'award_category_id',
    ]);
    final name = _firstString(value, const [
      'name',
      'category_name',
      'award_category_name',
    ]);
    return AwardCategories.fromId(
      id,
      otherName: name,
      otherColor: _parseColor(
        value['color'] ?? value['color_hex'] ?? value['award_category_color'],
      ),
    );
  }

  static const String firstPlaceId = 'first_place';
  static const String secondPlaceId = 'second_place';
  static const String thirdPlaceId = 'third_place';
  static const String consolationId = 'consolation';
  static const String participationId = 'participation';
  static const String otherId = 'other';

  static final Map<String, AwardCategories> presets = {
    firstPlaceId: AwardCategories(
      id: firstPlaceId,
      name: 'รางวัลชนะเลิศ',
      color: Color(0xFFB8860B),
    ),
    secondPlaceId: AwardCategories(
      id: secondPlaceId,
      name: 'รางวัลรองชนะเลิศอันดับ 1',
      color: Color(0xFF546E7A),
    ),
    thirdPlaceId: AwardCategories(
      id: thirdPlaceId,
      name: 'รางวัลรองชนะเลิศอันดับ 2',
      color: Color(0xFF795548),
    ),
    consolationId: AwardCategories(
      id: consolationId,
      name: 'รางวัลชมเชย',
      color: Color(0xFFE65100),
    ),
    participationId: AwardCategories(
      id: participationId,
      name: 'เข้าร่วม',
      color: Color(0xFFC62828),
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
