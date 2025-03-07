import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/audio_handler.dart';

class SVGADisplayScreen extends StatefulWidget {
  final String svgaUrl;
  const SVGADisplayScreen({super.key, required this.svgaUrl});

  @override
  _SVGADisplayScreenState createState() => _SVGADisplayScreenState();
}

class _SVGADisplayScreenState extends State<SVGADisplayScreen> with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  bool isLoading = true;
  bool isMuted = false;
  bool hasAudio = false;
  bool isPlaying = false;
  final AudioHandler _audioHandler = AudioHandler();

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    loadAnimation();
  }

  Future<void> loadAnimation() async {
    try {
      final videoItem = await loadVideoItem(widget.svgaUrl);
      if (mounted) {
        setState(() {
          animationController.videoItem = videoItem;
          hasAudio = videoItem.audios.isNotEmpty;
          isLoading = false;
        });
        animationController.forward(from: 0.0);
        isPlaying = true;
        if (hasAudio) {
          _audioHandler.playAudioFromSVGA(videoItem);
        }
      }
    } catch (e) {
      print("❌ Error loading SVGA: $e");
    }
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _audioHandler.muteAudio(isMuted);
    });
  }

  void togglePlayPause() {
    setState(() {
      if (isPlaying) {
        animationController.stop();
        _audioHandler.pauseAudio();
      } else {
        animationController.forward(from: 0.0);
        if (hasAudio) {
          _audioHandler.resumeAudio(); // Ensures audio resumes on play
        }
      }
      isPlaying = !isPlaying;
    });
  }

  Future<MovieEntity> loadVideoItem(String url) async {
    try {
      if (url.startsWith("http")) {
        return await SVGAParser.shared.decodeFromURL(url);
      } else {
        return await SVGAParser.shared.decodeFromAssets(url);
      }
    } catch (e) {
      print("❌ Error loading SVGA file: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _audioHandler.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SVGA Animation")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Stack(
          alignment: Alignment.bottomRight,
          children: [
            Center(
              child: SizedBox(

                child: animationController.videoItem != null
                    ? SVGAImage( controller: animationController,)
                    : const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: togglePlayPause,
                  ),
                  if (hasAudio)
                    IconButton(
                      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                      onPressed: toggleMute,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
