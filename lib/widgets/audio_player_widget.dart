import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<bool>? _playingSubscription;
  bool _isPlaying = false;
  bool _showInfo = false;

  final String _trackTitle = 'chimes [chill lofi]';
  final String _artistName = 'Snoozybeats';
  static const String _streamUrl = String.fromEnvironment('STREAM_URL');
  static const double _volume = 0.5;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(_streamUrl);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setLoopMode(LoopMode.one);

      _playingSubscription = _audioPlayer.playingStream.listen((playing) {
        if (!mounted) return;
        setState(() {
          _isPlaying = playing;
        });
      });

      if (!kIsWeb) {
        await _audioPlayer.play();
      }

      await _audioPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint('Stream Error: $e');
    }
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Playback Error: $e');
    }
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      left: 10,
      child: SafeArea(
        child: Card(
          color: Colors.white.withValues(alpha: 0.85),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _showInfo = !_showInfo),
                        icon: const Icon(Icons.info_outline),
                      ),
                      IconButton(
                        onPressed: () => _togglePlay(),
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _showInfo
                        ? Padding(
                            key: const ValueKey('track-info'),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Track Title : $_trackTitle',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Artist : $_artistName',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                      'https://on.soundcloud.com/nPTynxZ4Ho1fVjjepE',
                                    );

                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Image.network(
                                        'https://cdn.prod.website-files.com/62a0a0168756b795debc65bc/69ef2abb9234e119f18b3687_Cloudmark%20Minimum%20size.webp',
                                        height: 10,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Listen on SoundCloud'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('no-track-info')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
