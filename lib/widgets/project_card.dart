import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/project_model.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.returnPath = '/projects',
  });

  final ProjectModel project;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(
          Uri(
            path: '/projects/${project.id}',
            queryParameters: {'returnPath': returnPath},
          ).toString(),
        ),
        child: SizedBox(
          width: 320,
          height: 360,
          child: Stack(
            children: [
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: Colors.black12,
                      child: OptimizedNetworkImage(
                        url: project.backgroundUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            project.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Divider(),
                          const SizedBox(height: 4),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxLines = (constraints.maxHeight / 15)
                                    .floor()
                                    .clamp(1, 1000)
                                    .toInt();

                                return Text(
                                  project.description.trim(),
                                  maxLines: maxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (project.isFeatured)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.yellow,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
