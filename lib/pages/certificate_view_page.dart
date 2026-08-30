import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/utils/image_downloader.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';
import 'package:sukonlanat_portfolio/widgets/project_card.dart';
import 'package:sukonlanat_portfolio/widgets/template_app_bar.dart';

class CertificateViewPage extends StatefulWidget {
  const CertificateViewPage({
    super.key,
    required this.certificate,
    this.certificateId,
    this.returnPath = '/certificates',
  });

  const CertificateViewPage.fromId({
    super.key,
    required this.certificateId,
    this.returnPath = '/certificates',
  }) : certificate = null;

  final CertificateModel? certificate;
  final String? certificateId;
  final String returnPath;

  @override
  State<CertificateViewPage> createState() => _CertificateViewPageState();
}

class _CertificateViewPageState extends State<CertificateViewPage> {
  late Future<CertificateModel?> _certificateFuture;

  @override
  void initState() {
    super.initState();
    if (widget.certificate == null) {
      _certificateFuture = CertificateRepository().fetchCertificateById(
        widget.certificateId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.certificate == null) {
      return FutureBuilder<CertificateModel?>(
        future: _certificateFuture,
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
                      ? 'ไม่สามารถโหลดข้อมูลเกียรติบัตรได้'
                      : 'ไม่พบข้อมูลเกียรติบัตร',
                ),
              ),
            );
          }

          return _buildCertificate(context, snapshot.data!);
        },
      );
    }

    return _buildCertificate(context, widget.certificate!);
  }

  Widget _buildCertificate(BuildContext context, CertificateModel certificate) {
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
              certificate.backgroundUrl,
              overlayTitle: isNarrowScreen
                  ? _buildTitle(context, certificate)
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
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        if (!isNarrowScreen) _buildTitle(context, certificate),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            Chip(
                              label: Text(
                                certificate.awardCategories.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  certificate.awardCategories.color,
                            ),
                            Chip(
                              label: Text(
                                certificate.competitionLevel.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  certificate.competitionLevel.color,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (certificate.datePeriod.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'วันที่: ${certificate.datePeriod}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    Text(
                      'ผู้จัด: ${certificate.organizer}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Divider(height: 32, color: Colors.white),
                    Text(
                      certificate.description,
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (certificate.imagesUrl.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 32,
                  childAspectRatio: 4 / 3,
                  maxCrossAxisExtent: 400,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGalleryTile(
                    context,
                    certificate.imagesUrl[index],
                    index,
                  ),
                  childCount: certificate.imagesUrl.length,
                  addAutomaticKeepAlives: false,
                ),
              ),
            ),
          if (certificate.relatedProjects.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 48, color: Colors.white),
                    Text(
                      'โครงงานที่เกี่ยวข้อง',
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
                      children: certificate.relatedProjects
                          .take(5)
                          .map(
                            (project) => ProjectCard(
                              project: project,
                              returnPath: '/certificates/${certificate.id}',
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
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

  Widget _buildTitle(BuildContext context, CertificateModel certificate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            certificate.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (certificate.isFeatured)
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
