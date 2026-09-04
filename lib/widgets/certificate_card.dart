import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/widgets/optimized_network_image.dart';

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
      margin: EdgeInsets.zero,
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
                        url: certificate.backgroundUrl,
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
                            certificate.name,
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
                                  certificate.description.trim(),
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
                        _buildCategoryChip(
                          certificate.awardCategories.name,
                          certificate.awardCategories.color,
                        ),
                        const SizedBox(height: 8),
                        _buildCategoryChip(
                          certificate.competitionLevel.name,
                          certificate.competitionLevel.color,
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

  Widget _buildCategoryChip(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Chip(
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: color,
        ),
      ),
    );
  }
}
