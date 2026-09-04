import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/services/project_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';
import 'package:sukonlanat_portfolio/widgets/certificate_card.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';
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
          return const Scaffold(body: Center(child: LoadingWidget()));
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
          style: const ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TemplateAppBar(returnPath: widget.returnPath),
      body: CustomScrollView(
        cacheExtent: 400,
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context, project.backgroundUrl)),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, 0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(context, project),
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, String imageUrl) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;

    if (isNarrowScreen) {
      return SizedBox(
        height: 360,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
                stops: [0.3, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: OptimizedNetworkImage(
                url: imageUrl,
                fit: BoxFit.cover,
                errorIconSize: 64,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: OptimizedNetworkImage(
                url: imageUrl,
                fit: BoxFit.cover,
                errorIconSize: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ProjectModel project) {
    return Row(
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
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Icon(Icons.star_rounded, color: Colors.yellow, size: 30),
          ),
      ],
    );
  }
}
