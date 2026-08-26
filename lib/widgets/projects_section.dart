import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/services/project_repository.dart';
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
        final content = projects.isEmpty
            ? const Center(child: Text('ไม่พบข้อมูลโครงการ'))
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 32,
                children: projects.map((project) {
                  return ProjectCard(
                    project: project,
                    returnPath: widget.returnPath,
                  );
                }).toList(),
              );

        return widget.embedded
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: content,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: content,
              );
      },
    );
  }
}
