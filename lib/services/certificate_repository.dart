import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/models/award_categories.dart';
import 'package:sukonlanat_portfolio/models/competition_level.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CertificateRepository {
  CertificateRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  Future<List<CertificateModel>>? _certificatesCache;
  Future<List<CertificateModel>>? _featuredCertificatesCache;

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
  }) {
    if (table == 'certificates') {
      return _certificatesCache ??= _fetchCertificates(table);
    }

    return _fetchCertificates(table);
  }

  Future<List<CertificateModel>> _fetchCertificates(String table) async {
    final rows = await _client
        .schema('public')
        .from(table)
        .select()
        .order('order_id', ascending: true);
    return _attachRelatedProjects(
      rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false),
    );
  }

  Future<List<CertificateModel>> fetchFeaturedCertificates() {
    return _featuredCertificatesCache ??= _fetchFeaturedCertificates();
  }

  Future<List<CertificateModel>> _fetchFeaturedCertificates() async {
    final rows = await _client
        .schema('public')
        .from('certificates')
        .select()
        .eq('is_featured', true)
        .order('order_id', ascending: true);

    return _attachRelatedProjects(
      rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false),
    );
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
    if (row == null) return null;
    return (await _attachRelatedProjects([
      Map<String, dynamic>.from(row),
    ])).first;
  }

  Future<List<CertificateModel>> _attachRelatedProjects(
    List<Map<String, dynamic>> certificates,
  ) async {
    if (certificates.isEmpty) return const [];
    final certificateIds = certificates
        .map((row) => row['id'])
        .whereType<num>()
        .toList();
    final links = await _client
        .schema('public')
        .from('project_competitions')
        .select('competition_id, project_id')
        .inFilter('competition_id', certificateIds);
    final projectIds = links
        .whereType<Map>()
        .map((row) => row['project_id'])
        .whereType<num>()
        .toSet()
        .toList();
    if (projectIds.isEmpty) {
      return certificates.map(CertificateModel.fromMap).toList(growable: false);
    }
    final projects = await _client
        .schema('public')
        .from('projects')
        .select()
        .inFilter('id', projectIds);
    final projectsById = <num, Map<String, dynamic>>{
      for (final row in projects.whereType<Map>())
        row['id'] as num: Map<String, dynamic>.from(row),
    };
    final relatedByCertificate = <num, List<Map<String, dynamic>>>{};
    for (final link in links.whereType<Map>()) {
      final certificateId = link['competition_id'];
      final project = projectsById[link['project_id']];
      if (certificateId is num && project != null) {
        relatedByCertificate.putIfAbsent(certificateId, () => []).add(project);
      }
    }
    return certificates
        .map((certificate) {
          return CertificateModel.fromMap({
            ...certificate,
            'related_projects':
                relatedByCertificate[certificate['id']] ?? const [],
          });
        })
        .toList(growable: false);
  }
}
