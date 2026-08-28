import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/services/certificate_repository.dart';
import 'package:sukonlanat_portfolio/utils/thai_date_formatter.dart';
import 'package:sukonlanat_portfolio/widgets/certificate_card.dart';
import 'package:sukonlanat_portfolio/widgets/loading_widget.dart';

class CertificatesSection extends StatefulWidget {
  const CertificatesSection({
    super.key,
    this.repository,
    this.featuredOnly = false,
    this.showFilter = true,
    this.returnPath = '/certificates',
    this.embedded = false,
  });

  final CertificateRepository? repository;
  final bool featuredOnly;
  final bool showFilter;
  final String returnPath;
  final bool embedded;

  @override
  State<CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends State<CertificatesSection> {
  late final Future<List<CertificateModel>> _certificatesFuture;
  String? _awardFilter;
  String? _levelFilter;
  bool _featuredFilter = false;

  bool get _hasActiveFilters =>
      _awardFilter != null || _levelFilter != null || _featuredFilter;

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
          return Center(child: LoadingWidget());
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
                      certificate.competitionLevel.name == _levelFilter) &&
                  (!_featuredFilter || certificate.isFeatured);
            })
            .toList(growable: false);
        final displayedCertificates = widget.featuredOnly
            ? filtered.take(5).toList(growable: false)
            : filtered;
        final latestCreatedAt = _latestCreatedAt(certificates);

        final certificateList = displayedCertificates.isEmpty
            ? const Center(child: Text('ไม่พบข้อมูลเกียรติบัตร'))
            : SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 32,
                  children: displayedCertificates
                      .map(
                        (certificate) => CertificateCard(
                          certificate: certificate,
                          returnPath: widget.returnPath,
                        ),
                      )
                      .toList(),
                ),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showFilter)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  children: [
                    if (latestCreatedAt != null)
                      Expanded(
                        child: Text(
                          'แก้ไขล่าสุด: ${_formatTimestamp(latestCreatedAt)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _hasActiveFilters ? _clearFilters : null,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('ล้างการกรอง'),
                    ),
                    const SizedBox(width: 8),
                    _hasActiveFilters
                        ? FilledButton.icon(
                            onPressed: () =>
                                _showFilterSheet(context, certificates),
                            icon: const Icon(Icons.filter_list),
                            label: const Text('กรองแล้ว'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () =>
                                _showFilterSheet(context, certificates),
                            icon: const Icon(Icons.filter_list),
                            label: const Text('กรอง'),
                          ),
                  ],
                ),
              ),
            if (widget.embedded)
              certificateList
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  child: certificateList,
                ),
              ),
          ],
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _awardFilter = null;
      _levelFilter = null;
      _featuredFilter = false;
    });
  }

  DateTime? _latestCreatedAt(List<CertificateModel> certificates) {
    DateTime? latest;
    for (final certificate in certificates) {
      final createdAt = certificate.createdAt;

      if (createdAt != null && (latest == null || createdAt.isAfter(latest))) {
        latest = createdAt;
      }
    }

    return latest;
  }

  String _formatTimestamp(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '${formatThaiDate(localDateTime)} $hour:$minute น.';
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
    var selectedFeatured = _featuredFilter;

    Widget filterContent() {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'กรองเกียรติบัตร',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedAward ?? '',
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่รางวัล',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('ทั้งหมด'),
                    ),
                    ...awards.map(
                      (award) =>
                          DropdownMenuItem(value: award, child: Text(award)),
                    ),
                  ],
                  onChanged: (value) => setSheetState(
                    () => selectedAward = value?.isEmpty == true ? null : value,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel ?? '',
                  decoration: const InputDecoration(
                    labelText: 'ระดับการแข่งขัน',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('ทั้งหมด'),
                    ),
                    ...levels.map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    ),
                  ],
                  onChanged: (value) => setSheetState(
                    () => selectedLevel = value?.isEmpty == true ? null : value,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selectedFeatured,
                  title: const Text('แสดงเฉพาะรายการเด่น'),
                  onChanged: (value) =>
                      setSheetState(() => selectedFeatured = value ?? false),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _awardFilter = selectedAward;
                          _levelFilter = selectedLevel;
                          _featuredFilter = selectedFeatured;
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
      );
    }

    if (MediaQuery.sizeOf(context).width >= 600) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: filterContent(),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => filterContent(),
      );
    }
  }
}
