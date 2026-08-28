import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/services/activity_repository.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/services/project_repository.dart';
import 'package:sukonlanat_portfolio/services/university_data_controller.dart';
import 'package:sukonlanat_portfolio/widgets/activities_section.dart';
import 'package:sukonlanat_portfolio/widgets/certificates_section.dart';
import 'package:sukonlanat_portfolio/widgets/fetch_university_data.dart';
import 'package:sukonlanat_portfolio/widgets/markdown_reader.dart';
import 'package:sukonlanat_portfolio/widgets/top_widget.dart';
import 'package:sukonlanat_portfolio/widgets/university_intro_video.dart';
import 'package:sukonlanat_portfolio/widgets/projects_section.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.universityId});

  final String? universityId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CertificateRepository certificateRepository;
  late ProjectRepository projectRepository;
  late ActivityRepository activityRepository;

  @override
  void initState() {
    super.initState();

    certificateRepository = CertificateRepository();
    projectRepository = ProjectRepository();
    activityRepository = ActivityRepository();

    _loadUniversityData();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.universityId != widget.universityId) {
      _loadUniversityData();
    }
  }

  void _loadUniversityData() {
    universityDataController.load(widget.universityId);
  }

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            const fullTitle = "Sukonlanat's Portfolio";
            const shortTitle = "Portfolio";

            final textPainter = TextPainter(
              text: TextSpan(
                text: fullTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              maxLines: 1,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final showShortTitle = textPainter.didExceedMaxLines;

            return Row(
              children: [
                Expanded(
                  child: Text(
                    showShortTitle ? shortTitle : fullTitle,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: isNarrowScreen
            ? [
                PopupMenuButton<String>(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.list_rounded, color: Colors.black),
                  onSelected: (value) => context.go('/$value'),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'certificates',
                      child: Text('Certificates'),
                    ),
                    PopupMenuItem(value: 'projects', child: Text('Projects')),
                    PopupMenuItem(
                      value: 'activities',
                      child: Text('Activites'),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ]
            : [
                TextButton(
                  onPressed: () => context.go('/certificates'),
                  child: const Text(
                    'Certificates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/projects'),
                  child: const Text(
                    'Projects',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/activities'),
                  child: const Text(
                    'Activites',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
              ],
        centerTitle: false,
        backgroundColor: Colors.white10.withAlpha(120),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height,
                ),
                child: Wrap(children: [FetchUniversityData()]),
              ),
              const SizedBox(height: 50),
              const Divider(color: Colors.white),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 800
                      ? 3
                      : constraints.maxWidth >= 500
                      ? 2
                      : 1;
                  const spacing = 35.0;
                  final itemWidth = crossAxisCount == 3
                      ? (constraints.maxWidth - spacing * 2) / 3
                      : crossAxisCount == 2
                      ? (constraints.maxWidth - spacing) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: FutureBuilder<List<CertificateModel>>(
                          future: certificateRepository.fetchCertificates(),
                          builder: (context, snapshot) => _buildStat(
                            'Certificates',
                            snapshot.data?.length ?? 0,
                            context,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: FutureBuilder<List<ProjectModel>>(
                          future: projectRepository.fetchProjects(),
                          builder: (context, snapshot) => _buildStat(
                            'Projects',
                            snapshot.data?.length ?? 0,
                            context,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: FutureBuilder<List<ActivityModel>>(
                          future: activityRepository.fetchActivities(),
                          builder: (context, snapshot) => _buildStat(
                            'Activities',
                            snapshot.data?.length ?? 0,
                            context,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              const Divider(color: Colors.white),
              const SizedBox(height: 50),
              AnimatedBuilder(
                animation: universityDataController,
                builder: (context, _) {
                  final introduceLink = universityDataController.introduceLink;

                  return Column(
                    children: [
                      Wrap(
                        spacing: 32,
                        runSpacing: 32,
                        children: [
                          if (introduceLink != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'คลิปวิดีโอแนะนำตัวหลักสูตร ',
                                            ),
                                            TextSpan(
                                              text: universityDataController
                                                  .degreeName,
                                              style: TextStyle(
                                                color: universityDataController
                                                    .color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      UniversityIntroVideo(url: introduceLink),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (universityDataController.sop != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'สาเหตุที่อยากเข้าศึกษาต่อในหลักสูตร ',
                                            ),
                                            TextSpan(
                                              text: universityDataController
                                                  .degreeName,
                                              style: TextStyle(
                                                color: universityDataController
                                                    .color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      MarkdownReader(
                                        url: universityDataController.sop!,
                                        strongColor:
                                            universityDataController.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (universityDataController.introduceLink != null ||
                              universityDataController.sop != null) {
                            return Column(
                              children: [
                                const SizedBox(height: 50),
                                const Divider(color: Colors.white),
                                const SizedBox(height: 50),
                              ],
                            );
                          }

                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  spacing: 32,
                  children: [
                    Column(
                      children: [
                        TopWidget(
                          text: 'Top Certificates',
                          path: '/certificates',
                        ),
                        const SizedBox(height: 16),
                        CertificatesSection(
                          repository: certificateRepository,
                          featuredOnly: true,
                          showFilter: false,
                          returnPath: '/',
                          embedded: true,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        TopWidget(text: 'Top Projects', path: '/projects'),
                        const SizedBox(height: 16),
                        ProjectsSection(
                          repository: projectRepository,
                          featuredOnly: true,
                          returnPath: '/',
                          embedded: true,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        TopWidget(text: 'Top Activities', path: '/activities'),
                        const SizedBox(height: 16),
                        ActivitiesSection(
                          repository: activityRepository,
                          returnPath: '/',
                          embedded: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Divider(color: Colors.white),
              const SizedBox(height: 50),
              Text(
                'Made with ❤︎⁠ by Sukonlanat Thawonfung',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://github.com/cybloxboi/sukonlanat-portfolio',
                  );

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text(
                  'Source Code (GitHub)',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String title, int value, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          value.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
