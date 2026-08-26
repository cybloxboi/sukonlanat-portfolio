import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';

class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    this.returnPath = '/certificates',
  });

  final CertificateModel certificate;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go(
            Uri(
              path: '/certificates/${certificate.id}',
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
                        certificate.backgroundUrl,
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
                          certificate.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Divider(),
                        const SizedBox(height: 4),
                        Text(
                          certificate.description.trim(),
                          maxLines: 4,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Chip(
                            label: Text(
                              certificate.awardCategories.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: certificate.awardCategories.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Chip(
                            label: Text(
                              certificate.competitionLevel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: certificate.competitionLevel.color,
                          ),
                        ),
                      ],
                    ),
                    if (certificate.isFeatured)
                      Icon(Icons.star_rounded, color: Colors.yellow, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
