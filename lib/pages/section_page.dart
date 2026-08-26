import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/widgets/certificates_section.dart';
import 'package:sukonlanat_portfolio/widgets/empty_section.dart';
import 'package:sukonlanat_portfolio/widgets/projects_section.dart';
import 'package:sukonlanat_portfolio/widgets/template_scaffold.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
    this.selectedCertificate,
  });

  final String title;
  final String description;
  final String? selectedCertificate;

  @override
  Widget build(BuildContext context) {
    return TemplateScaffold(
      title: title,
      body: title == 'Certificates'
          ? const CertificatesSection()
          : title == 'Projects'
          ? const ProjectsSection()
          : EmptySection(
              description: description,
              selectedCertificate: selectedCertificate,
            ),
    );
  }
}
