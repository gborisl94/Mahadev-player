import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LoopPlayerBB()));

class LoopPlayerBB extends StatefulWidget { @override State<LoopPlayerBB> createState() => _LoopPlayerBBState(); }

class _LoopPlayerBBState extends State<LoopPlayerBB> {
  final player = AudioPlayer();
  String? filePath;
  Duration posA = Duration(seconds: 3);
  Duration posB = Duration(seconds: 15);
  int loopCount = 4;
  int loopDone = 0;
  bool isLooping = true;

  @override
  void initState() {
    super.initState();
    player.positionStream.listen((p) {
      if (isLooping && p >= posB) {
        player.seek(posA);
        setState(() => loopDone++);
      }
    });
  }

  Future pickFile() async {
    await Permission.storage.request();
    await Permission.audio.request();
    var r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r != null) {
      filePath = r.files.single.path!;
      await player.setFilePath(filePath!);
      setState(() {});
    }
  }

  Future generateFile() async {
    if (filePath == null) return;
    final dir = Directory('/storage/emulated/0/Music/BB Loops');
    if (!await dir.exists()) await dir.create(recursive: true);
    String out = "${dir.path}/LOOP_${DateTime.now().millisecondsSinceEpoch}.mp3";
    String cmd = "-y -ss ${posA.inSeconds} -to ${posB.inSeconds} -i \"$filePath\" -c:a libmp3lame -q:a 2 \"$out\"";
    if (loopCount > 1) {
      String listPath = "${(await getTemporaryDirectory()).path}/list.txt";
      String listContent = List.generate(loopCount, (_) => "file '$out'").join("\n");
      await File(listPath).writeAsString(listContent);
      String outLoop = "${dir.path}/LOOP_${loopCount}X_${DateTime.now().millisecondsSinceEpoch}.mp3";
      String cmdConcat = "-y -f concat -safe 0 -i $listPath -c copy $outLoop";
      await FFmpegKit.execute(cmd);
      await FFmpegKit.execute(cmdConcat);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Généré: $outLoop")));
    } else {
      await FFmpegKit.execute(cmd);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Généré: $out")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Loop Player BB", style: TextStyle(color: Colors.yellow))),
      body: Column(
        children: [
          if (filePath != null) Text(filePath!.split('/').last, style: TextStyle(color: Colors.white)),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow), onPressed: () => setState(() => posA = player.position), child: Text("SET A ${posA.inSeconds}s")),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow), onPressed: () => setState(() => posB = player.position), child: Text("SET B ${posB.inSeconds}s")),
          ]),
          Text("Boucles: $loopDone / $loopCount x", style: TextStyle(color: Colors.yellow)),
          Slider(value: loopCount.toDouble(), min: 1, max: 20, divisions: 19, label: "${loopCount}x", onChanged: (v) => setState(() => loopCount = v.toInt())),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: Icon(Icons.skip_previous, color: Colors.yellow, size: 40), onPressed: () => player.seek(posA)),
            IconButton(icon: Icon(player.playing ? Icons.pause : Icons.play_arrow, color: Colors.yellow, size: 50), onPressed: () => player.playing ? player.pause() : player.play()),
            IconButton(icon: Icon(Icons.skip_next, color: Colors.yellow, size: 40), onPressed: () => player.seek(posB)),
          ]),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black), onPressed: generateFile, child: Text("GÉNÉRER FICHIER AUDIO")),
          ElevatedButton(onPressed: pickFile, child: Text("Charger Audio")),
        ],
      ),
    );
  }
}