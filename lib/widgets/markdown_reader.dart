import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MarkdownReader extends StatefulWidget {
  const MarkdownReader({
    super.key,
    required this.url,
    required this.strongColor,
  });

  final String url;
  final Color strongColor;

  @override
  State<MarkdownReader> createState() => _MarkdownReaderState();
}

class _MarkdownReaderState extends State<MarkdownReader> {
  static final Map<String, String> _markdownCache = {};
  late Future<String> markdown;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    markdown = fetchMarkdown();
  }

  @override
  void didUpdateWidget(covariant MarkdownReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        markdown = fetchMarkdown();
        _isExpanded = false;
      });
    }
  }

  Future<String> fetchMarkdown() async {
    final cachedMarkdown = _markdownCache[widget.url];
    if (cachedMarkdown != null) return cachedMarkdown;

    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode != 200) {
      throw Exception('ไม่สามารถอ่าน Markdown ได้');
    }

    final content = utf8.decode(response.bodyBytes);
    _markdownCache[widget.url] = content;
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: markdown,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.stretchedDots(
              color: Theme.of(context).colorScheme.onSurface,
              size: 40,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? '';
        final lines = data.split('\n');
        const collapsedLineCount = 3;
        final hasMore = lines.length > collapsedLineCount;
        final displayedData = _isExpanded || !hasMore
            ? data
            : '${lines.take(collapsedLineCount).join('\n')}\n\n...';

        final markdownBody = MarkdownBody(
          data: displayedData,
          shrinkWrap: true,
          styleSheet: MarkdownStyleSheet(
            strong: TextStyle(
              color: widget.strongColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        return AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              markdownBody,
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _isExpanded = !_isExpanded);
                      },
                      child: Text(_isExpanded ? 'ย่อ' : 'แสดงทั้งหมด'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
