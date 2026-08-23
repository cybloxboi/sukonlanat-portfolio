import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';

class CertificateViewPage extends StatelessWidget {
  const CertificateViewPage({
    super.key,
    required this.certificate,
    this.returnPath = '/certificates',
  });

  final CertificateModel certificate;
  final String returnPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                              Icon(
                                Icons.star_rounded,
                                color: Colors.yellow,
                                size: 40,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  certificate.awardCategories.name,
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor:
                                    certificate.awardCategories.color,
                              ),
                              const SizedBox(width: 16),
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
                      Text('Certificate ID: ${certificate.id}'),
                      const SizedBox(height: 8),
                      Text('ผู้จัด: ${certificate.organizer}'),
                      const Divider(height: 32, color: Colors.white),
                      Text(
                        certificate.description,
                        style: TextStyle(fontSize: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
