import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';

void main() {
  runApp(SVGAApp());
}

class SVGAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black87,
      ),
      home: SVGAHomeScreen(),
    );
  }
}

class SVGAHomeScreen extends StatelessWidget {
  final List<String> svgaFiles = [
    "assets/lion.svga",
    "assets/sample.svga",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SVGA Player", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: svgaFiles.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SVGADisplayScreen(svgaUrl: svgaFiles[index]),
                ),
              ),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blueAccent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "SVGA ${index + 1}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
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

class _SVGADisplayScreenState extends State<SVGADisplayScreen>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    final videoItem = await _loadVideoItem(widget.svgaUrl);
    if (mounted) {
      setState(() {
        isLoading = false;
        animationController.videoItem = videoItem;
        animationController.repeat();
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SVGA Animation", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blueGrey[900]),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blueAccent)
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SVGAImage( controller:animationController,),
          ),
        ),
      ),
    );
  }
}

Future<MovieEntity> _loadVideoItem(String image) {
  if (image.startsWith("http")) {
    return SVGAParser.shared.decodeFromURL(image);
  } else {
    return SVGAParser.shared.decodeFromAssets(image);
  }
}
