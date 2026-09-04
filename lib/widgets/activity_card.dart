import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.returnPath = '/activities',
  });

  final ActivityModel activity;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go(
            Uri(
              path: '/activities/${activity.id}',
              queryParameters: {'returnPath': returnPath},
            ).toString(),
          );
        },
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
                        url: activity.backgroundUrl,
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
                            activity.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                                  activity.description.trim(),
                                  maxLines: maxLines,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
              if (activity.isFeatured)
                Positioned(
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
