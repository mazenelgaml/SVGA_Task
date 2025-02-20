import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SvgaWebView extends StatefulWidget {
  const SvgaWebView({Key? key}) : super(key: key);

  @override
  _SvgaWebViewState createState() => _SvgaWebViewState();
}

class _SvgaWebViewState extends State<SvgaWebView> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    String htmlContent = await rootBundle.loadString('assets/index.html');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVGA Animation')),
      body: _controller != null
          ? WebViewWidget(controller: _controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
