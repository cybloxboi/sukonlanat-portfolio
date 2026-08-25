import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/widgets/certificate_card.dart';

class CertificatesSection extends StatefulWidget {
  const CertificatesSection({
    super.key,
    this.repository,
    this.featuredOnly = false,
    this.showFilter = true,
    this.embedded = false,
  });

  final CertificateRepository? repository;
  final bool featuredOnly;
  final bool showFilter;
  final bool embedded;

  @override
  State<CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends State<CertificatesSection> {
  late final Future<List<CertificateModel>> _certificatesFuture;
  String? _awardFilter;
  String? _levelFilter;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository ?? CertificateRepository();
    _certificatesFuture = widget.featuredOnly
        ? repository.fetchFeaturedCertificates()
        : repository.fetchCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CertificateModel>>(
      future: _certificatesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                Image.asset('assets/images/loading.gif', height: 80),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('ไม่สามารถโหลดข้อมูลเกียรติบัตรได้'));
        }

        final certificates = snapshot.data ?? const <CertificateModel>[];
        final filtered = certificates
            .where((certificate) {
              return (_awardFilter == null ||
                      certificate.awardCategories.name == _awardFilter) &&
                  (_levelFilter == null ||
                      certificate.competitionLevel.name == _levelFilter);
            })
            .toList(growable: false);
        final displayedCertificates = widget.featuredOnly
            ? filtered.take(5).toList(growable: false)
            : filtered;

        final certificateList = displayedCertificates.isEmpty
            ? const Center(child: Text('ไม่พบข้อมูลเกียรติบัตร'))
            : Wrap(
                spacing: 32,
                runSpacing: 32,
                children: certificates
                    .take(5)
                    .map(
                      (certificate) =>
                          CertificateCard(certificate: certificate),
                    )
                    .toList(),
              );

        return Column(
          children: [
            if (widget.showFilter)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _showFilterSheet(context, certificates),
                    icon: const Icon(Icons.filter_list),
                    label: const Text('กรอง'),
                  ),
                ),
              ),
            widget.embedded
                ? certificateList
                : Expanded(child: certificateList),
          ],
        );
      },
    );
  }

  Future<void> _showFilterSheet(
    BuildContext context,
    List<CertificateModel> certificates,
  ) async {
    final awards = certificates
        .map((certificate) => certificate.awardCategories.name)
        .toSet()
        .toList();
    final levels = certificates
        .map((certificate) => certificate.competitionLevel.name)
        .toSet()
        .toList();
    var selectedAward = _awardFilter;
    var selectedLevel = _levelFilter;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedAward,
                  decoration: const InputDecoration(
                    labelText: 'Award Category',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('ทั้งหมด'),
                    ),
                    ...awards.map(
                      (award) =>
                          DropdownMenuItem(value: award, child: Text(award)),
                    ),
                  ],
                  onChanged: (value) =>
                      setSheetState(() => selectedAward = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Competition Level',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('ทั้งหมด'),
                    ),
                    ...levels.map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    ),
                  ],
                  onChanged: (value) =>
                      setSheetState(() => selectedLevel = value),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _awardFilter = selectedAward;
                          _levelFilter = selectedLevel;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('ใช้ตัวกรอง'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
