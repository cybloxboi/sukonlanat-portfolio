import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/services/activity_repository.dart';
import 'package:sukonlanat_portfolio/utils/image_downloader.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/template_app_bar.dart';

class ActivityViewPage extends StatefulWidget {
  const ActivityViewPage({
    super.key,
    required this.activity,
    this.activityId,
    this.returnPath = '/activities',
  });

  const ActivityViewPage.fromId({
    super.key,
    required this.activityId,
    this.returnPath = '/activities',
  }) : activity = null;

  final ActivityModel? activity;
  final String? activityId;
  final String returnPath;

  @override
  State<ActivityViewPage> createState() => _ActivityViewPageState();
}

class _ActivityViewPageState extends State<ActivityViewPage> {
  late Future<ActivityModel?> _activityFuture;

  @override
  void initState() {
    super.initState();
    if (widget.activity == null) {
      _activityFuture = ActivityRepository().fetchActivityById(
        widget.activityId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activity == null) {
      return FutureBuilder<ActivityModel?>(
        future: _activityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: LoadingWidget()));
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => context.go(widget.returnPath),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: Center(
                child: Text(
                  snapshot.hasError
                      ? 'ไม่สามารถโหลดข้อมูลกิจกรรมได้'
                      : 'ไม่พบข้อมูลกิจกรรม',
                ),
              ),
            );
          }

          return _buildActivity(context, snapshot.data!);
        },
      );
    }

    return _buildActivity(context, widget.activity!);
  }

  Widget _buildActivity(BuildContext context, ActivityModel activity) {
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
                        activity.backgroundUrl,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }

                              return _buildImageLoadingCard(context);
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
                            activity.backgroundUrl,
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

                                  return _buildImageLoadingCard(context);
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
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  activity.name,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              if (activity.isFeatured)
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.yellow,
                                  size: 30,
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (activity.datePeriod.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'วันที่: ${activity.datePeriod}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      Text(
                        'ผู้จัด: ${activity.organizer}',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Divider(height: 32, color: Colors.white),
                      Text(
                        activity.description,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Divider(height: 32, color: Colors.white),
                      Text(
                        'เกียรติบัตร และรูปภาพกิจกรรม',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  mainAxisSpacing: 32,
                                  crossAxisSpacing: 32,
                                  childAspectRatio: 4 / 3,
                                  maxCrossAxisExtent: 400,
                                ),
                            itemCount: activity.imagesUrl.length,
                            itemBuilder: (context, index) {
                              final imageUrl = activity.imagesUrl[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: Material(
                                  color: Theme.of(context).cardColor,
                                  child: InkWell(
                                    onTap: () => _showImageViewer(
                                      context,
                                      imageUrl,
                                      index,
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      frameBuilder:
                                          (
                                            context,
                                            child,
                                            frame,
                                            wasSynchronouslyLoaded,
                                          ) {
                                            if (wasSynchronouslyLoaded ||
                                                frame != null) {
                                              return child;
                                            }

                                            return _buildImageLoadingCard(
                                              context,
                                            );
                                          },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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

  Widget _buildImageLoadingCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: LoadingWidget()),
    );
  }

  void _showImageViewer(BuildContext context, String imageUrl, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('รูปภาพเกียรติบัตรและกิจกรรม'),
              actions: [
                if (supportsImageDownload)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      tooltip: 'ดาวน์โหลดรูปภาพ',
                      onPressed: () async {
                        await downloadImage(
                          imageUrl,
                          'certificate-${index + 1}.jpg',
                        );
                      },
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
              ],
              leading: IconButton(
                tooltip: 'ปิด',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        }

                        return _buildImageLoadingCard(context);
                      },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
