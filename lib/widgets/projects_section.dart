import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/services/project_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/project_card.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({
    super.key,
    this.repository,
    this.featuredOnly = false,
    this.returnPath = '/projects',
    this.embedded = false,
  });

  final ProjectRepository? repository;
  final bool featuredOnly;
  final String returnPath;
  final bool embedded;

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  late final Future<List<ProjectModel>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository ?? ProjectRepository();
    _projectsFuture = widget.featuredOnly
        ? repository.fetchFeaturedProjects()
        : repository.fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProjectModel>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LoadingWidget());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('ไม่สามารถโหลดข้อมูลโครงการได้'));
        }

        final projects = snapshot.data ?? const <ProjectModel>[];
        final projectList = projects.isEmpty
            ? const Center(child: Text('ไม่พบข้อมูลโครงการ'))
            : SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: widget.embedded
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  spacing: 16,
                  runSpacing: 32,
                  children: projects.map((project) {
                    return ProjectCard(
                      project: project,
                      returnPath: widget.returnPath,
                    );
                  }).toList(),
                ),
              );

        final latestCreatedAt = _lastestCreatedAt(projects);

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
              projectList
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: projectList,
                ),
              ),
          ],
        );
      },
    );
  }

  DateTime? _lastestCreatedAt(List<ProjectModel> projects) {
    DateTime? latest;

    for (final project in projects) {
      final createdAt = project.createdAt;

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
