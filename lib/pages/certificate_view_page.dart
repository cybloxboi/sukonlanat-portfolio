import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/utils/image_downloader.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white10.withAlpha(120),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.go(widget.returnPath),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
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
                        certificate.backgroundUrl,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                            certificate.backgroundUrl,
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
                              const SizedBox(width: 24),
                              if (certificate.isFeatured)
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.yellow,
                                  size: 30,
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
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    certificate.awardCategories.color,
                              ),
                              Chip(
                                label: Text(
                                  certificate.competitionLevel.name,
                                  style: TextStyle(color: Colors.white),
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
                            itemCount: certificate.imagesUrl.length,
                            itemBuilder: (context, index) {
                              final imageUrl = certificate.imagesUrl[index];
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
