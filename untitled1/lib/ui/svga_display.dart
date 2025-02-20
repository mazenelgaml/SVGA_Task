import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svgaplayer_flutter/player.dart';
import '../controllers/audio_controller.dart';


class SVGADisplayScreen extends StatefulWidget {
  final String svgaUrl;
  SVGADisplayScreen({required this.svgaUrl});

  @override
  _SVGADisplayScreenState createState() => _SVGADisplayScreenState();
}

class _SVGADisplayScreenState extends State<SVGADisplayScreen> with SingleTickerProviderStateMixin {



/*  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }*/

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioController>(
        init: AudioController(widget,mounted),
    builder: (AudioController controller) {
    return Scaffold(
      appBar: AppBar(title: Text("SVGA Animation")),
      body: Center(
        child: controller.isLoading
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
                        child: SVGAImage(controller.animationController),
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
                              child: Center(child: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow))),
                          onPressed: controller.togglePlayPause,
                        ),
                        if (controller.hasAudio)
                          IconButton(
                            icon: Container(
                                width: 50,
                                height: 50,
                                decoration:BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(100)
                                ) ,
                                child: Center(child: Icon(controller.isMuted ? Icons.volume_off : Icons.volume_up))),
                            onPressed: controller.toggleMute,
                          ),
                      ],
                    ),
                  ),
                ]
              ),
            ),
      ),
    );});
  }
}