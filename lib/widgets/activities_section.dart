import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/services/activity_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';
import 'package:sukonlanat_portfolio/widgets/activity_card.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';

class ActivitiesSection extends StatefulWidget {
  const ActivitiesSection({
    super.key,
    this.repository,
    this.returnPath = '/activities',
    this.embedded = false,
  });

  final ActivityRepository? repository;
  final String returnPath;
  final bool embedded;

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection> {
  late final Future<List<ActivityModel>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository ?? ActivityRepository();
    _activitiesFuture = repository.fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityModel>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LoadingWidget());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('ไม่สามารถโหลดข้อมูลกิจกรรมได้'));
        }

        final activities = snapshot.data ?? const <ActivityModel>[];
        final latestCreatedAt = _latestCreatedAt(activities);

        final activityList = activities.isEmpty
            ? const Center(child: Text('ไม่พบข้อมูลกิจกรรม'))
            : SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 16,
                  runSpacing: 32,
                  children: activities
                      .map(
                        (activity) => ActivityCard(
                          activity: activity,
                          returnPath: widget.returnPath,
                        ),
                      )
                      .toList(),
                ),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.embedded)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  children: [
                    if (latestCreatedAt != null)
                      Expanded(
                        child: Text(
                          'แก้ไขล่าสุด: ${_formatTimestamp(latestCreatedAt)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ),
            if (widget.embedded)
              activityList
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: activityList,
                ),
              ),
          ],
        );
      },
    );
  }

  DateTime? _latestCreatedAt(List<ActivityModel> activities) {
    DateTime? latest;

    for (final activity in activities) {
      final createdAt = activity.createdAt;

      if (createdAt != null && (latest == null || createdAt.isAfter(latest))) {
        latest = createdAt;
      }
    }

    return latest;
  }

  String _formatTimestamp(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '${formatThaiDate(localDateTime)} $hour:$minute น.';
  }
}
