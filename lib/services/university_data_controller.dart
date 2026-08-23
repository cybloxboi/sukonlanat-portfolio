import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sukonlanat_portfolio/models/university_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UniversityDataController extends ChangeNotifier {
  UniversityDataController._();

  static final UniversityDataController instance = UniversityDataController._();
  static const Object _unset = Object();

  static const UniversityData emptyData = UniversityData(
    name: 'World',
    shortName: 'World',
    color: Color(0xFFFFFFFF),
  );

  final Map<String, UniversityData> _cache = {};

  UniversityData _data = emptyData;
  String? _universityId;
  String? _errorMessage;
  bool _isLoading = false;
  int _requestVersion = 0;

  UniversityData get data => _data;
  String get name => _data.name;
  String get shortName => _data.shortName;
  Color get color => _data.color;
  String? get degreeName => _data.degreeName;
  String? get projectName => _data.projectName;
  String? get introduceLink => _data.introduceLink;
  String? get universityId => _universityId;
  String? get sop => _data.sop;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasUniversity => _data != emptyData;

  Future<void> loadFromUri() async {
    await load(Uri.base.queryParameters['id']);
  }

  Future<void> load(String? universityId) async {
    final id = universityId?.trim();

    if (id == null || id.isEmpty) {
      if (_universityId != null && (_isLoading || hasUniversity)) return;

      _setState(
        data: emptyData,
        universityId: null,
        errorMessage: null,
        isLoading: false,
      );
      return;
    }

    if (_universityId == id && (_isLoading || hasUniversity)) return;

    final requestVersion = ++_requestVersion;
    _setState(
      data: emptyData,
      universityId: id,
      errorMessage: null,
      isLoading: true,
    );

    final cachedData = _cache[id];
    if (cachedData != null) {
      _setState(
        data: cachedData,
        universityId: id,
        errorMessage: null,
        isLoading: false,
      );
      return;
    }

    try {
      debugPrint('Fetching university: $id');

      final response = await Supabase.instance.client
          .from('universities')
          .select(
            'name, short_name, color_hex, degree_name, project_name, introduce_link, sop',
          )
          .eq('id', id)
          .maybeSingle();

      if (requestVersion != _requestVersion) return;

      if (response == null) {
        debugPrint('ไม่พบข้อมูลมหาวิทยาลัยนี้');
        _setState(isLoading: false);
        return;
      }

      final university = UniversityData(
        name: _asString(response['name'], fallback: emptyData.name),
        shortName: _asString(
          response['short_name'],
          fallback: _asString(response['name'], fallback: emptyData.shortName),
        ),
        color: _parseColor(response['color_hex']) ?? emptyData.color,
        degreeName: _asNullableString(response['degree_name']),
        projectName: _asNullableString(response['project_name']),
        introduceLink: _asNullableString(response['introduce_link']),
        sop: _asNullableString(response['sop']),
      );

      _cache[id] = university;
      _setState(
        data: university,
        universityId: id,
        errorMessage: null,
        isLoading: false,
      );
    } catch (error) {
      if (requestVersion != _requestVersion) return;

      debugPrint('เกิดข้อผิดพลาดในการโหลดข้อมูล: $error');
      _setState(errorMessage: error.toString(), isLoading: false);
    }
  }

  void _setState({
    UniversityData? data,
    Object? universityId = _unset,
    String? errorMessage,
    bool? isLoading,
  }) {
    _data = data ?? _data;
    if (universityId != _unset) {
      _universityId = universityId as String?;
    }
    _errorMessage = errorMessage;
    _isLoading = isLoading ?? _isLoading;
    notifyListeners();
  }

  static String _asString(Object? value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _asNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static Color? _parseColor(Object? value) {
    final hex = value?.toString().replaceFirst('#', '');
    if (hex == null || hex.isEmpty) return null;

    final normalized = hex.length == 6 ? 'ff$hex' : hex;
    final parsed = int.tryParse(normalized, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
}

final universityDataController = UniversityDataController.instance;
