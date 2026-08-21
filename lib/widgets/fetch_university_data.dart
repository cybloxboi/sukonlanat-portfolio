import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/university_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FetchUniversityData extends StatefulWidget {
  const FetchUniversityData({super.key, this.universityId});

  final String? universityId;

  @override
  State<FetchUniversityData> createState() => _FetchUniversityDataState();
}

class _FetchUniversityDataState extends State<FetchUniversityData> {
  static final Map<String, UniversityData> _cache = {};

  String _universityName = 'World';
  String _universityShortName = 'World';
  Color _universityColor = Colors.white;
  String? _degreeName;
  String? _projectName;

  @override
  void initState() {
    super.initState();
    _fetchUniversityData(_resolvedUniversityId);
  }

  @override
  void didUpdateWidget(covariant FetchUniversityData oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.universityId != widget.universityId) {
      _fetchUniversityData(_resolvedUniversityId);
    }
  }

  String? get _resolvedUniversityId {
    final widgetId = widget.universityId?.trim();
    if (widgetId != null && widgetId.isNotEmpty) return widgetId;

    final urlId = Uri.base.queryParameters['id']?.trim();
    return urlId?.isNotEmpty == true ? urlId : null;
  }

  Future<void> _fetchUniversityData(String? universityId) async {
    if (mounted) {
      setState(() {
        _universityName = 'World';
        _universityShortName = 'World';
        _universityColor = Colors.white;
        _degreeName = null;
        _projectName = null;
      });
    }

    try {
      if (universityId == null || universityId.isEmpty) {
        debugPrint('University id is missing from the URL.');
        return;
      }

      final cachedRecord = _cache[universityId];
      if (cachedRecord != null) {
        if (!mounted) return;
        setState(() {
          _universityName = cachedRecord.name;
          _universityShortName = cachedRecord.shortName;
          _universityColor = cachedRecord.color;
          _degreeName = cachedRecord.degreeName;
          _projectName = cachedRecord.projectName;
        });
        debugPrint('Using cached university: $universityId');
        return;
      }

      debugPrint('Fetching university: $universityId');

      final data = await Supabase.instance.client
          .from('universities')
          .select('name, short_name, color_hex, degree_name, project_name')
          .eq('id', universityId)
          .maybeSingle();

      if (data != null) {
        if (!mounted) return;
        setState(() {
          _universityName = data['name'] ?? _universityName;
          _universityShortName = data['short_name'] ?? _universityShortName;

          if (data['color_hex'] != null) {
            _universityColor = _parseColor(data['color_hex']);
          }

          _degreeName = data['degree_name'];
          _projectName = data['project_name'];

          _cache[universityId] = UniversityData(
            name: _universityName,
            shortName: _universityShortName,
            color: _universityColor,
            degreeName: _degreeName,
            projectName: _projectName,
          );
        });
      } else {
        debugPrint('ไม่พบข้อมูลมหาวิทยาลัยนี้');
      }
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    }
  }

  Color _parseColor(String hexString) {
    final buffer = StringBuffer();

    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }

    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 900),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: SizedBox(
          key: ValueKey(_universityName),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final baseStyle = DefaultTextStyle.of(
                    context,
                  ).style.copyWith(color: Colors.white, fontSize: 40);

                  final fullNameSpan = TextSpan(
                    style: baseStyle,
                    children: [
                      const TextSpan(text: 'Hello, '),
                      TextSpan(
                        text: '$_universityName!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _universityColor,
                        ),
                      ),
                    ],
                  );

                  final textPainter = TextPainter(
                    text: fullNameSpan,
                    textDirection: TextDirection.ltr,
                    maxLines: 2,
                  )..layout(maxWidth: constraints.maxWidth);

                  final bool isExceeded = textPainter.didExceedMaxLines;

                  final displayName = isExceeded
                      ? _universityShortName
                      : _universityName;

                  return RichText(
                    key: ValueKey(displayName),
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: baseStyle,
                      children: [
                        const TextSpan(text: 'Hello, '),
                        TextSpan(
                          text: '$displayName!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _universityColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  if (_degreeName != null)
                    ConstrainedBox(
                      key: ValueKey(_universityName),
                      constraints: BoxConstraints(maxWidth: 450),
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    if (_degreeName != null)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'หลักสูตร  • ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_degreeName!)),
                                        ],
                                      ),
                                    if (_projectName != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'โครงการ  • ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(_projectName!),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 450),
                    child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  foregroundImage: AssetImage(
                                    'assets/images/profile_image.png',
                                  ),
                                  radius: 50,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text('Hi!'),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(
                                          context,
                                        ).style,
                                        children: [
                                          const TextSpan(text: 'ผมชื่อว่า '),
                                          TextSpan(
                                            text: 'นายศุกลณัฏฐ์ ถาวรฟัง',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(
                                          context,
                                        ).style,
                                        children: [
                                          const TextSpan(text: 'ชื่อเล่นว่า '),
                                          TextSpan(
                                            text: 'ติวเตอร์',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(text: 'ระดับชั้น : '),
                                        TextSpan(
                                          text: 'มัธยมศึกษาปีที่ 6',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(text: 'แผนการเรียน : '),
                                        TextSpan(
                                          text: 'วิทยาศาสตร์-คณิตศาสตร์',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(text: 'ห้องเรียน : '),
                                        TextSpan(
                                          text: 'ห้องเรียนพิเศษคณิตศาสตร์',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(text: 'โรงเรียน : '),
                                        TextSpan(
                                          text: 'อำนาจเจริญ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(text: 'GPAX 4 : '),
                                        TextSpan(
                                          text: '4.00',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
