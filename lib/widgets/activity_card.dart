import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';

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
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.black12,
                      child: Image.network(
                        activity.backgroundUrl,
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }

                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: LoadingWidget(),
                              );
                            },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                            ),
                      ),
                    ),
                  ),
                  Padding(
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
                        Text(
                          activity.description.trim(),
                          maxLines: 4,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
