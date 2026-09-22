import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MahadevApp());

class MahadevApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahadev Player B',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> videos = [];

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result!= null) {
      setState(() {
        videos.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahadev Player B - Privé'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: videos.isEmpty
         ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 100, color: Colors.orange),
                  SizedBox(height: 20),
                  Text('Aucune vidéo', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Appuie sur + pour ajouter', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  leading: Icon(Icons.play_circle, color: Colors.orange, size: 40),
                  title: Text(videos[i].path.split('/').last),
                  subtitle: Text('Privé - Lecture flottante dispo'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoScreen(file: videos[i]),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: pickVideo,
        child: Icon(Icons.add),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final File file;
  VideoScreen({required this.file});
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
     ..initialize().then((_) {
        setState(() { _isInit = true; });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last, style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_in_picture),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mode flottant B activé - minimise l\'app')),
              );
            },
          )
        ],
      ),
      body: Center(
        child: _isInit
           ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(color: Colors.orange),
      ),
      floatingActionButton: _isInit
         ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying? _controller.pause() : _controller.play();
                });
              },
              child: Icon(_controller.value.isPlaying? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}