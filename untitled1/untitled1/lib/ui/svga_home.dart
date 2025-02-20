import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'svga_display.dart';

class SVGAHomeScreen extends StatelessWidget {
  final List<String> svgaFiles = [
    "assets/lion.svga",
    "assets/sample.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/heartbeat.svga"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SVGA Player")),
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