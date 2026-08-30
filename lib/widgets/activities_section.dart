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
    this.featuredOnly = false,
    this.returnPath = '/activities',
    this.embedded = false,
  });

  final ActivityRepository? repository;
  final bool featuredOnly;
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
    _activitiesFuture = widget.featuredOnly
        ? repository.fetchFeaturedActivities()
        : repository.fetchActivities();
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
        final displayedActivities = widget.embedded
            ? activities.take(5).toList(growable: false)
            : activities;
        final latestCreatedAt = _latestCreatedAt(activities);

        return Column(
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
            if (displayedActivities.isEmpty)
              if (widget.embedded)
                const Center(child: Text('ไม่พบข้อมูลกิจกรรม'))
              else
                const Expanded(child: Center(child: Text('ไม่พบข้อมูลกิจกรรม')))
            else if (widget.embedded)
              _buildActivityGrid(displayedActivities)
            else
              Expanded(child: _buildActivityGrid(displayedActivities)),
          ],
        );
      },
    );
  }

  Widget _buildActivityGrid(List<ActivityModel> activities) {
    return GridView.builder(
      padding: widget.embedded
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24, 0, 24, 24),
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      cacheExtent: 500,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 360,
        mainAxisSpacing: 32,
        crossAxisSpacing: 16,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) => ActivityCard(
        activity: activities[index],
        returnPath: widget.returnPath,
      ),
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
