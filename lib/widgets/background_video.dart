import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  const BackgroundVideo({super.key, required this.child});

  final Widget child;

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late final VideoPlayerController _controller;
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
      setState(() => _videoReady = true);
      await _controller.play();
    } catch (error) {
      debugPrint('Background video error: $error');
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

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _videoReady ? 1 : 0,
            duration: const Duration(milliseconds: 1200),
            child: _videoReady
                ? Container(
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.8
                          : 0.2,
                    ),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: Opacity(
                          opacity: 0.6,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}
