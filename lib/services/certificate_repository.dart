import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/models/award_categories.dart';
import 'package:sukonlanat_portfolio/models/competition_level.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CertificateRepository {
  CertificateRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AwardCategories>> fetchAwardCategories({
    String table = 'award_categories',
  }) async {
    final rows = await _client.schema('public').from(table).select();
    return rows
        .whereType<Map>()
        .map((row) => AwardCategories.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<CompetitionLevel>> fetchCompetitionLevels({
    String table = 'competition_levels',
  }) async {
    final rows = await _client.schema('public').from(table).select();
    return rows
        .whereType<Map>()
        .map((row) => CompetitionLevel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<CertificateModel>> fetchCertificates({
    String table = 'certificates',
  }) async {
    var query = _client.schema('public').from(table).select();

    final rows = await query.order('start_time', ascending: false);
    return rows
        .whereType<Map>()
        .map((row) => CertificateModel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<CertificateModel>> fetchFeaturedCertificates() async {
    final rows = await _client
        .schema('public')
        .from('certificates')
        .select()
        .eq('is_featured', true)
        .order('start_time', ascending: false);

    return rows
        .whereType<Map>()
        .map((row) => CertificateModel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<CertificateModel?> fetchCertificateById(String id) async {
    final numericId = int.tryParse(id);
    if (numericId == null) return null;

    final row = await _client
        .schema('public')
        .from('certificates')
        .select()
        .eq('id', numericId)
        .maybeSingle();
    return row == null ? null : CertificateModel.fromMap(row);
  }
}
