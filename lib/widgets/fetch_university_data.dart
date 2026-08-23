import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/services/university_data_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FetchUniversityData extends StatelessWidget {
  const FetchUniversityData({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: universityDataController,
      builder: (context, child) {
        final university = universityDataController.data;

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
            child: ConstrainedBox(
              key: ValueKey(university.name),
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height,
              ),
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
                            text: '${university.name}!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: university.color,
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
                          ? university.shortName
                          : university.name;

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
                                color: university.color,
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
                      if (university.degreeName != null)
                        ConstrainedBox(
                          key: ValueKey(university.name),
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
                                        if (university.degreeName != null)
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
                                              Expanded(
                                                child: Text(
                                                  university.degreeName!,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (university.projectName != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16,
                                            ),
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
                                                  child: Text(
                                                    university.projectName!,
                                                  ),
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
                              mainAxisSize: MainAxisSize.min,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              const TextSpan(
                                                text: 'ผมชื่อว่า ',
                                              ),
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
                                              const TextSpan(
                                                text: 'ชื่อเล่นว่า ',
                                              ),
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
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
                                          children: [
                                            const TextSpan(
                                              text: 'ระดับชั้น : ',
                                            ),
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
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
                                          children: [
                                            const TextSpan(
                                              text: 'แผนการเรียน : ',
                                            ),
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
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
                                          children: [
                                            const TextSpan(
                                              text: 'ห้องเรียน : ',
                                            ),
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
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
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
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
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
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: () async {
                                      final uri = Uri.parse(
                                        'https://github.com/cybloxboi',
                                      );

                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/github_logo_${Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light'}.png',
                                          height: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('GitHub'),
                                      ],
                                    ),
                                  ),
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
      },
    );
  }
}
