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
        final displayedProjects = widget.featuredOnly
            ? projects.take(5).toList(growable: false)
            : projects;

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
            if (displayedProjects.isEmpty)
              if (widget.embedded)
                const Center(child: Text('ไม่พบข้อมูลโครงการ'))
              else
                const Expanded(child: Center(child: Text('ไม่พบข้อมูลโครงการ')))
            else if (widget.embedded)
              _buildProjectGrid(displayedProjects)
            else
              Expanded(child: _buildProjectGrid(displayedProjects)),
          ],
        );
      },
    );
  }

  Widget _buildProjectGrid(List<ProjectModel> projects) {
    return GridView.builder(
      padding: widget.embedded
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24, 0, 24, 24),
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      cacheExtent: 500,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisExtent: 420,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          ProjectCard(project: projects[index], returnPath: widget.returnPath),
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
