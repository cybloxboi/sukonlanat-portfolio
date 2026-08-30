import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/activity_model.dart';
import 'package:sukonlanat_portfolio/services/activity_repository.dart';
import 'package:sukonlanat_portfolio/utils/image_downloader.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';
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
            return const Scaffold(body: Center(child: LoadingWidget()));
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
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TemplateAppBar(returnPath: widget.returnPath),
      body: CustomScrollView(
        cacheExtent: 400,
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(
              context,
              activity.backgroundUrl,
              overlayTitle: isNarrowScreen
                  ? _buildTitle(context, activity)
                  : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, 0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isNarrowScreen) _buildTitle(context, activity),
                    const SizedBox(height: 16),
                    if (activity.datePeriod.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'วันที่: ${activity.datePeriod}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    Text(
                      'ผู้จัด: ${activity.organizer}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Divider(height: 32, color: Colors.white),
                    Text(
                      activity.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
                  ],
                ),
              ),
            ),
          ),
          if (activity.imagesUrl.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  maxCrossAxisExtent: 400,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGalleryTile(
                    context,
                    activity.imagesUrl[index],
                    index,
                  ),
                  childCount: activity.imagesUrl.length,
                  addAutomaticKeepAlives: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    String imageUrl, {
    Widget? overlayTitle,
  }) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;
    final image = OptimizedNetworkImage(
      url: imageUrl,
      fit: BoxFit.cover,
      errorIconSize: 64,
    );

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
              child: image,
            ),
            if (overlayTitle != null)
              Positioned(top: 24, left: 24, right: 24, child: overlayTitle),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(aspectRatio: 16 / 9, child: image),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ActivityModel activity) {
    return Row(
      children: [
        Expanded(
          child: Text(
            activity.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (activity.isFeatured)
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Icon(Icons.star_rounded, color: Colors.yellow, size: 30),
          ),
      ],
    );
  }

  Widget _buildGalleryTile(BuildContext context, String imageUrl, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          onTap: () => _showImageViewer(context, imageUrl, index),
          child: OptimizedNetworkImage(
            url: imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            errorIconSize: 48,
          ),
        ),
      ),
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
                          'activity-${index + 1}.jpg',
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
                child: OptimizedNetworkImage(
                  url: imageUrl,
                  fit: BoxFit.contain,
                  maxDecodeDimension: 3072,
                  filterQuality: FilterQuality.high,
                  errorIconSize: 64,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
