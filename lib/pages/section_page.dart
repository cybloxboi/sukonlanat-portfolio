import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/widgets/activities_section.dart';
import 'package:sukonlanat_portfolio/widgets/certificates_section.dart';
import 'package:sukonlanat_portfolio/widgets/projects_section.dart';
import 'package:sukonlanat_portfolio/widgets/template_scaffold.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TemplateScaffold(
      title: title,
      body: title == 'Certificates'
          ? const CertificatesSection()
          : title == 'Projects'
          ? const ProjectsSection()
          : const ActivitiesSection(),
    );
  }
}
