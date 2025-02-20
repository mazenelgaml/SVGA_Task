import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/ui/svga_home.dart';
import 'controllers/audio_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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