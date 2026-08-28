import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityRepository {
  ActivityRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  PostgrestFilterBuilder<PostgrestList> get query =>
      _client.schema('public').from('activities').select();

  Future<List<ActivityModel>> fetchActivities() async {
    final rows = await query.order('order_id', ascending: true);
    return rows
        .whereType<Map>()
        .map((row) => ActivityModel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<ActivityModel>> fetchFeaturedActivities() async {
    final rows = await query
        .eq('is_featured', true)
        .order('order_id', ascending: true);

    return rows
        .whereType<Map>()
        .map((row) => ActivityModel.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<ActivityModel?> fetchActivityById(String id) async {
    final numericId = int.tryParse(id);

    if (numericId == null) {
      return null;
    }

    final row = await query.eq('id', numericId).maybeSingle();

    if (row == null) {
      return null;
    }

    return ActivityModel.fromMap(Map<String, dynamic>.from(row));
  }
}
