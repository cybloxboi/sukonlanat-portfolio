import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class UniversityIntroVideo extends StatefulWidget {
  const UniversityIntroVideo({super.key, required this.url});

  final String url;

  @override
  State<UniversityIntroVideo> createState() => _UniversityIntroVideoState();
}

class _UniversityIntroVideoState extends State<UniversityIntroVideo> {
  late final String _viewType;
  late final web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = 'university-intro-video-${identityHashCode(this)}';
    _iframe = _createIframe(widget.url);
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  @override
  void didUpdateWidget(covariant UniversityIntroVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _iframe.src = widget.url;
    }
  }

  web.HTMLIFrameElement _createIframe(String url) {
    return web.HTMLIFrameElement()
      ..src = url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow =
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
      ..setAttribute('allowfullscreen', 'true');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
