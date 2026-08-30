import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRepository {
  ProjectRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  Future<List<ProjectModel>>? _projectsCache;
  Future<List<ProjectModel>>? _featuredProjectsCache;
  PostgrestFilterBuilder<PostgrestList> get query =>
      _client.schema('public').from('projects').select();

  Future<List<ProjectModel>> fetchProjects() async {
    return _projectsCache ??= _fetchProjects(
      query.order('order_id', ascending: true),
    );
  }

  Future<List<ProjectModel>> fetchFeaturedProjects() async {
    return _featuredProjectsCache ??= _fetchProjects(
      query.eq('is_featured', true).order('order_id', ascending: true),
    );
  }

  Future<List<ProjectModel>> _fetchProjects(
    PostgrestTransformBuilder<PostgrestList> projectQuery,
  ) async {
    final projectRows = await projectQuery;
    final projects = projectRows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
    if (projects.isEmpty) return const [];

    final projectIds = projects
        .map((row) => row['id'])
        .whereType<num>()
        .toList();
    final links = await _client
        .schema('public')
        .from('project_competitions')
        .select('project_id, competition_id')
        .inFilter('project_id', projectIds);
    final certificateIds = links
        .whereType<Map>()
        .map((row) => row['competition_id'])
        .whereType<num>()
        .toSet()
        .toList();
    if (certificateIds.isEmpty) {
      return projects.map(ProjectModel.fromMap).toList(growable: false);
    }

    final certificates = await _client
        .schema('public')
        .from('certificates')
        .select()
        .inFilter('id', certificateIds);
    final certificatesById = <num, Map<String, dynamic>>{
      for (final row in certificates.whereType<Map>())
        row['id'] as num: Map<String, dynamic>.from(row),
    };
    final relatedByProject = <num, List<Map<String, dynamic>>>{};
    for (final link in links.whereType<Map>()) {
      final projectId = link['project_id'];
      final certificate = certificatesById[link['competition_id']];
      if (projectId is num && certificate != null) {
        relatedByProject.putIfAbsent(projectId, () => []).add(certificate);
      }
    }

    return projects
        .map((project) {
          return ProjectModel.fromMap({
            ...project,
            'related_certificates': relatedByProject[project['id']] ?? const [],
          });
        })
        .toList(growable: false);
  }

  Future<ProjectModel?> fetchProjectById(String id) async {
    final numericId = int.tryParse(id);

    if (numericId == null) {
      return null;
    }

    final projects = await _fetchProjects(query.eq('id', numericId));
    return projects.isEmpty ? null : projects.first;
  }
}
