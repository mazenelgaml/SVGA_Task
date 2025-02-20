import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';

class AudioController extends GetxController with GetTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late SVGAAnimationController animationController;
  bool isLoading = true;
  bool isMuted = false;
  bool hasAudio = false;
  bool isPlaying = true;
  final dynamic widget;
  final bool mounted;

  AudioController(this.widget, this.mounted);

  @override
  void onInit() {
    super.onInit();
    animationController = SVGAAnimationController(vsync: this);
    loadAnimation(widget, mounted);

  }

  Future<void> loadAnimation(dynamic widget, bool mounted) async {
    try {
      final videoItem = await loadVideoItem(widget.svgaUrl);
      if (mounted) {
        isLoading = false;
        animationController.videoItem = videoItem;
        hasAudio = videoItem.audios.isNotEmpty;
        animationController.repeat();
        isPlaying = true;
        update();
      }
    } catch (e) {
      print("Error loading SVGA: $e");
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    for (var audio in animationController.audioLayers) {
      audio.muteAudio(isMuted);
    }
    update();
  }

  void togglePlayPause() {
    if (isPlaying) {
      animationController.stop();
    } else {
      animationController.repeat();
    }
    isPlaying = !isPlaying;
    update();
  }

  void play(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    animationController.dispose();
    super.onClose();
  }



Future<MovieEntity> loadVideoItem(String image) async {
  try {
    if (image.startsWith("http")) {
      return await SVGAParser.shared.decodeFromURL(image);
    } else {
      return await SVGAParser.shared.decodeFromAssets(image);
    }
  } catch (e) {
    print("Error loading SVGA file: $e");
    rethrow;
  }
}
}
