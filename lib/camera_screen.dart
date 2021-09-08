import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:video_editor/app_model.dart';
import 'package:video_editor/main_screen.dart';
import 'package:video_editor/utils.dart';
import 'package:video_editor/video_trimming_screen.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final Duration videoDurationLimit;

  CameraScreen({required this.videoDurationLimit});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _controllerInitialized = false;
  bool _errorInitializingController = false;
  String _cameraName = '0'; // 1 == front camera, 0 == back camera
  bool _isRecordingVideo = false;
  Duration _recordingDuration = Duration(
    hours: 0,
    minutes: 0,
    seconds: 0,
  );

  @override
  void initState() {
    _initController();
    super.initState();
  }

  void _initController() {
    _controller = CameraController(
      CameraDescription(
        name: _cameraName,
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
      ResolutionPreset.max,
      enableAudio: true,
    );
    _controller.initialize().then((value) async {
      await _controller.setFocusMode(FocusMode.auto);
      setState(() {
        _controllerInitialized = true;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        _errorInitializingController = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Utils.pushReplacement(context, MainScreen());
        return true;
      },
      child: Scaffold(
        body: _controllerInitialized
            ? _getBody()
            : _errorInitializingController
                ? Center(
                    child: Text(
                      'Could not initialize camera',
                      style: TextStyle(fontSize: 32),
                    ),
                  )
                : Utils.circularLoader(context),
      ),
    );
  }

  Widget _getBody() {
    return Column(
      children: [
        Expanded(
          child: CameraPreview(
            _controller,
            child: Stack(
              children: [
                _getCaptureButton(),
                _getCameraToggleButton(),
                _getVideoRecordingDurationSection(),
                _getHeaderItems(),
                _getRecentVideos(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getRecentVideos() {
    return GetIt.I.get<AppModel>().recentVideosList.isEmpty
        ? Container()
        : Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...GetIt.I.get<AppModel>().recentVideosList.map(
                    (e) {
                      final controller = VideoPlayerController.file(e);
                      return FutureBuilder(
                        future: controller.initialize(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) return Container();
                          final chewieController = ChewieController(
                            videoPlayerController: controller,
                            autoPlay: false,
                            looping: false,
                            showControls: false,
                          );

                          return GestureDetector(
                            onTap: () {
                              Utils.pushReplacement(
                                  context, VideoTrimmingScreen(file: e));
                            },
                            child: Container(
                              margin: EdgeInsets.all(4),
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Chewie(
                                controller: chewieController,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).toList(),
                ],
              ),
            ),
          );
  }

  Widget _getHeaderItems() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Utils.pushReplacement(context, MainScreen());
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(Icons.close),
            ),
          ),
          // Expanded(
          //   child: SizedBox(),
          // ),
          // Container(
          //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(8),
          //     color: Colors.white.withOpacity(0.2),
          //   ),
          //   child: Text('Next'),
          // ),
        ],
      ),
    );
  }

  Widget _getVideoRecordingDurationSection() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
            bottom:
                GetIt.I.get<AppModel>().recentVideosList.isEmpty ? 124 : 200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.brightness_1,
              color: Colors.red,
              size: 12,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              _recordingDuration.toString().substring(2, 7),
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCameraToggleButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(
            bottom: GetIt.I.get<AppModel>().recentVideosList.isEmpty ? 32 : 100,
            right: 32),
        width: Utils.getScreenWidth(context) / 5,
        height: Utils.getScreenWidth(context) / 5,
        alignment: Alignment.center,
        child: _isRecordingVideo
            ? Container()
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _cameraName == '0' ? _cameraName = '1' : _cameraName = '0';
                    _initController();
                  });
                },
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 45,
                ),
              ),
      ),
    );
  }

  Widget _getCaptureButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () {
          _recordVideo();
        },
        child: Container(
          margin: EdgeInsets.only(
              bottom:
                  GetIt.I.get<AppModel>().recentVideosList.isEmpty ? 32 : 100),
          width: Utils.getScreenWidth(context) / 5,
          height: Utils.getScreenWidth(context) / 5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: _isRecordingVideo
              ? Icon(
                  Icons.brightness_1,
                  color: Colors.red,
                  size: 65,
                )
              : Icon(
                  Icons.video_call_rounded,
                  color: Colors.white,
                  size: 55,
                ),
        ),
      ),
    );
  }

  // UI ENDS HERE

  Future<void> _recordVideo() async {
    if (_isRecordingVideo) {
      _controller.stopVideoRecording().then((xFile) async {
        setState(() {
          _isRecordingVideo = false;
        });
        Utils.pushReplacement(
          context,
          VideoTrimmingScreen(
            file: File(xFile.path),
          ),
        );
      }).catchError((error) {
        print(error);
      });
    } else {
      await _controller.startVideoRecording();
      _isRecordingVideo = true;
      _startVideoTimer();
    }
  }

  Future<void> _startVideoTimer() async {
    int count = 0;
    while (_isRecordingVideo) {
      await Future.delayed(Duration(seconds: 1));
      count++;
      _recordingDuration = Duration(seconds: count);
      try {
        setState(() {});
        if (_recordingDuration.compareTo(widget.videoDurationLimit) == 0) {
          _recordVideo();
        }
      } catch (exc) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
