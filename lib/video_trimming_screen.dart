import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_editor/main_screen.dart';
import 'package:video_editor/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'app_model.dart';

class VideoTrimmingScreen extends StatefulWidget {
  final File file;

  VideoTrimmingScreen({required this.file});

  @override
  _VideoTrimmingScreenState createState() => _VideoTrimmingScreenState();
}

class _VideoTrimmingScreenState extends State<VideoTrimmingScreen> {
  final Trimmer _trimmer = Trimmer();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  double? _start = 0.0, _end;

  @override
  void initState() {
    GetIt.I.get<AppModel>().recentVideosList.add(widget.file);
    _loadVideo();
    _initVideoControllers();
    super.initState();
  }

  Future<void> _initVideoControllers() async {
    _videoPlayerController = VideoPlayerController.file(widget.file);
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      allowedScreenSleep: false,
    );
    setState(() {});
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: widget.file);
    setState(() {});
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    print('PATH_IS:${widget.file.path}');
    return WillPopScope(
      onWillPop: () async {
        Utils.pushReplacement(
          context,
          MainScreen(),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _chewieController == null
                      ? Container()
                      : Chewie(
                          controller: _chewieController!,
                        ),
                ),
                SizedBox(
                  height: 4,
                ),
                TrimEditor(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: Duration(minutes: 25),
                  onChangeStart: (value) {
                    _start = value;
                  },
                  onChangeEnd: (value) {
                    _end = value;
                  },
                  onChangePlaybackState: (value) {},
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    _trimmer
                        .saveTrimmedVideo(
                      startValue: _start!,
                      endValue: _end!,
                      videoFileName:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                    )
                        .then((value) {
                      GetIt.I
                          .get<AppModel>()
                          .selectedVideosList
                          .add(File(value));
                      Utils.pushReplacement(context, MainScreen());
                    }).catchError((error) {
                      setState(() {
                        _isLoading = false;
                      });
                    });

                    // Utils.pushReplacement(
                    //   context,
                    //   MainScreen(),
                    // );
                  },
                  icon: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _isLoading ? Utils.circularLoader(context) : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trimmer.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
