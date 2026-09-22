import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MahadevApp());

class MahadevApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => loading = true),
          onPageFinished: (_) => setState(() => loading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://mahadevbook.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mahadev Player'), backgroundColor: Colors.black),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (loading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}