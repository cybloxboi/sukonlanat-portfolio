import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.description,
    this.selectedCertificate,
  });

  final String title;
  final String description;
  final String? selectedCertificate;

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white10.withAlpha(120),
        centerTitle: false,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: isNarrowScreen
            ? [
                PopupMenuButton<String>(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.list_rounded, color: Colors.black),
                  onSelected: (value) => context.go('/$value'),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'certificates',
                      child: Text('Certificates'),
                    ),
                    PopupMenuItem(value: 'projects', child: Text('Projects')),
                    PopupMenuItem(
                      value: 'activities',
                      child: Text('Activites'),
                    ),
                    PopupMenuItem(value: 'about_me', child: Text('About Me')),
                  ],
                ),
                const SizedBox(width: 8),
              ]
            : [
                TextButton(
                  onPressed: () => context.go('/certificates'),
                  child: const Text(
                    'Certificates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/projects'),
                  child: const Text(
                    'Projects',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/activities'),
                  child: const Text(
                    'Activites',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/about_me'),
                  child: const Text(
                    'About Me',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: title == 'Certificates'
          ? _buildCertificatesBody(context)
          : _buildEmptyBody(),
    );
  }

  Widget _buildEmptyBody() {
    return Center(
      child: Text(
        selectedCertificate == null
            ? description
            : 'ข้อมูล Certificate ที่ส่งมา: $selectedCertificate',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildCertificatesBody(BuildContext context) {
    return FutureBuilder<List<CertificateModel>>(
      future: CertificateRepository().fetchCertificates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('ไม่สามารถโหลดข้อมูลเกียรติบัตรได้'));
        }
        final certificates = snapshot.data ?? const <CertificateModel>[];
        if (certificates.isEmpty) {
          return const Center(child: Text('ยังไม่มีข้อมูลเกียรติบัตร'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: certificates.length,
          itemBuilder: (context, index) {
            final certificate = certificates[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: certificate.awardCategories.color,
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.black,
                  ),
                ),
                title: Text(certificate.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รางวัล: ${certificate.awardCategories.name} • '
                      'ระดับ: ${certificate.competitionLevel.name}',
                    ),
                    Text(
                      'วันที่: ${formatThaiDateRange(certificate.startTime, certificate.endTime)}',
                    ),
                  ],
                ),
                onTap: () => context.go('/certificates/${certificate.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
