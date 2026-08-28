import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/services/project_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';
import 'package:sukonlanat_portfolio/widgets/certificate_card.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/template_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectViewPage extends StatefulWidget {
  const ProjectViewPage.fromId({
    super.key,
    required this.projectId,
    this.returnPath = '/projects',
  });

  final String projectId;
  final String returnPath;

  @override
  State<ProjectViewPage> createState() => _ProjectViewPageState();
}

class _ProjectViewPageState extends State<ProjectViewPage> {
  late final Future<ProjectModel?> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = ProjectRepository().fetchProjectById(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProjectModel?>(
      future: _projectFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: LoadingWidget()));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: TemplateAppBar(returnPath: widget.returnPath),
            body: Center(
              child: Text(
                snapshot.hasError
                    ? 'ไม่สามารถโหลดข้อมูลโครงการได้'
                    : 'ไม่พบข้อมูลโครงการ',
              ),
            ),
          );
        }

        return _buildProject(context, snapshot.data!);
      },
    );
  }

  Widget _buildProject(BuildContext context, ProjectModel project) {
    final links = <Widget>[
      if (project.projectUrl.isNotEmpty)
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.parse(project.projectUrl)),
          icon: const Icon(Icons.open_in_new),
          label: const Text('เปิดเว็บไซต์ผลงาน'),
        ),
      if (project.githubUrl.isNotEmpty)
        OutlinedButton.icon(
          onPressed: () => launchUrl(Uri.parse(project.githubUrl)),
          icon: const Icon(Icons.code),
          label: const Text('ดูซอร์สโค้ดผ่าน GitHub'),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TemplateAppBar(returnPath: widget.returnPath),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.sizeOf(context).width < 600) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.3, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(
                        project.backgroundUrl,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }

                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: LoadingWidget(),
                                ),
                              );
                            },
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 360,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 64,
                              ),
                            ),
                      ),
                    );
                  }

                  final imageWidth = constraints.maxWidth.clamp(0.0, 900.0);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: imageWidth,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            project.backgroundUrl,
                            fit: BoxFit.cover,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }

                                  return Card(
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: LoadingWidget(),
                                    ),
                                  );
                                },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Transform.translate(
                offset: Offset(
                  0,
                  MediaQuery.sizeOf(context).width > 600 ? 0 : -100,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          if (project.isFeatured)
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.yellow,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                      if (project.date != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'วันที่: ${formatThaiDate(project.date!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                      if (links.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(spacing: 12, runSpacing: 12, children: links),
                      ],
                      const Divider(height: 40, color: Colors.white),
                      Text(
                        project.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (project.relatedCertificates.isNotEmpty) ...[
                        const Divider(height: 48, color: Colors.white),
                        Text(
                          'การแข่งขันที่เกี่ยวข้อง',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: project.relatedCertificates
                              .map(
                                (certificate) => CertificateCard(
                                  certificate: certificate,
                                  returnPath: '/projects/${project.id}',
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
