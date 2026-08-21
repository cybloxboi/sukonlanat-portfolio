import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/widgets/audio_player_widget.dart';
import 'package:sukonlanat_portfolio/widgets/fetch_university_data.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.universityId});

  final String? universityId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;

  bool _videoReady = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://xzjguwrttwqcwskvmoxk.supabase.co/storage/v1/object/public/website-data/background_video.mp4',
      ),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);

      if (!mounted) return;

      setState(() {
        _videoReady = true;
      });

      await _controller.play();
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = _videoReady ? _controller.value.size : Size.zero;

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            const fullTitle = "Sukonlanat's Portfolio";
            const shortTitle = "Tutor's Portfolio";

            final textPainter = TextPainter(
              text: TextSpan(
                text: fullTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              maxLines: 1,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final showShortTitle = textPainter.didExceedMaxLines;

            return Text(
              showShortTitle ? shortTitle : fullTitle,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Certificates',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Projects',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Activites',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
        centerTitle: false,
        backgroundColor: Colors.white10.withAlpha(120),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _videoReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              child: _videoReady
                  ? FittedBox(
                      fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: Opacity(
                          opacity: 0.6,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: 101,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: MediaQuery.sizeOf(context).height,
                          child: Wrap(
                            children: [
                              FetchUniversityData(
                                universityId: widget.universityId,
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Item $index',
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          AudioPlayerWidget(),
        ],
      ),
    );
  }
}
