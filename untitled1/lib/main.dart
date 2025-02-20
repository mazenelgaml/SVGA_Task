import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/parser.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AudioController(), permanent: true);
  runApp(SVGAApp());
}

class SVGAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: SVGAHomeScreen(),
    );
  }
}

class SVGAHomeScreen extends StatelessWidget {
  final List<String> svgaFiles = [
    "assets/lion.svga",
    "assets/sample.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/heartbeat.svga"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SVGA Player"),leading: BackButton(onPressed: (){},),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: svgaFiles.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Get.to(() => SVGADisplayScreen(svgaUrl: svgaFiles[index])),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "SVGA ${index + 1}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SVGADisplayScreen extends StatefulWidget {
  final String svgaUrl;
  SVGADisplayScreen({required this.svgaUrl});

  @override
  _SVGADisplayScreenState createState() => _SVGADisplayScreenState();
}

class _SVGADisplayScreenState extends State<SVGADisplayScreen> with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  bool isLoading = true;
  bool isMuted = false;
  bool hasAudio = false;
  bool isPlaying = true;
  final audioController = Get.find<AudioController>();

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    try {
      final videoItem = await _loadVideoItem(widget.svgaUrl);
      if (mounted) {
        setState(() {
          isLoading = false;
          animationController.videoItem = videoItem;
          hasAudio = videoItem.audios.isNotEmpty;
          animationController.repeat();
          isPlaying = true;
        });


      }
    } catch (e) {
      print("Error loading SVGA: $e");
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      for (var audio in animationController.audioLayers) {
        audio.muteAudio(isMuted);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        animationController.stop();
      } else {
        animationController.repeat();
      }
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    if (isPlaying) {
      audioController.stop();
      animationController.stop();

    }
    audioController.stop();
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SVGA Animation")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SVGAImage(animationController),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasAudio)
                    InkWell(
                      onTap: _toggleMute,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
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

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    super.onClose();
  }
}

Future<MovieEntity> _loadVideoItem(String image) async {
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
