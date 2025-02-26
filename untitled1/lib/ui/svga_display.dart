import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';
import 'package:audioplayers/audioplayers.dart';


class SVGADisplayScreen extends StatefulWidget {
  final String svgaUrl;
  SVGADisplayScreen({required this.svgaUrl});

  @override
  _SVGADisplayScreenState createState() => _SVGADisplayScreenState();
}

class _SVGADisplayScreenState extends State<SVGADisplayScreen> with SingleTickerProviderStateMixin {

  final AudioPlayer _audioPlayer = AudioPlayer();
  late SVGAAnimationController animationController;
  bool isLoading = true;
  bool isMuted = false;
  bool hasAudio = false;
  bool isPlaying = true;




  @override
  void onInit() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    loadAnimation(widget, mounted);

  }

  Future<void> loadAnimation(dynamic widget, bool mounted) async {
setState(() async{
  try {
    final videoItem = await loadVideoItem(widget.svgaUrl);
    if (mounted) {
      isLoading = false;
      animationController.videoItem = videoItem;
      hasAudio = videoItem.audios.isNotEmpty;
      animationController.repeat();
      isPlaying = true;

    }
  } catch (e) {
    print("Error loading SVGA: $e");
  }
});
  }

  void toggleMute() {
 setState(() {
   isMuted = !isMuted;
   for (var audio in animationController.audioLayers) {
     audio.muteAudio(isMuted);
   }
 });

  }

  void togglePlayPause() {
setState(() {
  if (isPlaying) {
    animationController.stop();
  } else {
    animationController.repeat();
  }
  isPlaying = !isPlaying;
});

  }

  void play(String url) async {
setState(() async{
  try {
    await _audioPlayer.play(UrlSource(url));
  } catch (e) {
    print("Error playing audio: $e");
  }
});
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
    super.dispose();
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


  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: Text("SVGA Animation")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children:[

                  Center(
                    child: FittedBox(

                      fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: Get.width,
                        height: Get.height,
                        child: SVGAImage(animationController),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Container(
                            width: 50,
                              height: 50,
                              decoration:BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(100)
                              ) ,
                              child: Center(child: Icon(isPlaying ? Icons.pause : Icons.play_arrow))),
                          onPressed:togglePlayPause,
                        ),
                        if (hasAudio)
                          IconButton(
                            icon: Container(
                                width: 50,
                                height: 50,
                                decoration:BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(100)
                                ) ,
                                child: Center(child: Icon(isMuted ? Icons.volume_off : Icons.volume_up))),
                            onPressed: toggleMute,
                          ),
                      ],
                    ),
                  ),
                ]
              ),
            ),
      ),
    );
  }
}