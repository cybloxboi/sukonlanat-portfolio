import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/utils/image_downloader.dart';

class CertificateViewPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (certificate == null) {
      return FutureBuilder<CertificateModel?>(
        future: CertificateRepository().fetchCertificateById(certificateId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 40,
                ),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => context.go(returnPath),
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

    return _buildCertificate(context, certificate!);
  }

  Widget _buildCertificate(BuildContext context, CertificateModel certificate) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white10.withAlpha(120),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.go(returnPath),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShaderMask(
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
                  certificate.backgroundUrl,
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 360,
                    child: Icon(Icons.image_not_supported_outlined, size: 64),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -100),
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
                                  certificate.name,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              if (certificate.isFeatured)
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.yellow,
                                  size: 40,
                                ),
                            ],
                          ),
                          Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              Chip(
                                label: Text(
                                  certificate.awardCategories.name,
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor:
                                    certificate.awardCategories.color,
                              ),
                              Chip(
                                label: Text(
                                  certificate.competitionLevel.name,
                                  style: TextStyle(color: Colors.black),
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
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      Text(
                        'ผู้จัด: ${certificate.organizer}',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Divider(height: 32, color: Colors.white),
                      Text(
                        certificate.description,
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisSpacing: 32,
                              crossAxisSpacing: 32,
                              childAspectRatio: 4 / 3,
                              maxCrossAxisExtent: 400,
                            ),
                        itemCount: certificate.imagesUrl.length,
                        itemBuilder: (context, index) {
                          final imageUrl = certificate.imagesUrl[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: Material(
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: () =>
                                    _showImageViewer(context, imageUrl, index),
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

                                        return _buildImageLoadingCard(context);
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Image.asset('assets/images/loading.gif', height: 80),
            Text(
              'Loading...',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
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
