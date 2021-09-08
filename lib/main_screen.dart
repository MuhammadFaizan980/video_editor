import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/app_model.dart';
import 'package:video_editor/camera_screen.dart';
import 'package:video_editor/play_video_screen.dart';
import 'package:video_editor/utils.dart';
import 'package:video_editor/video_trimming_screen.dart';
import 'package:video_player/video_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MediaSelectionSheet(
                  onCameraSelected: () {
                    Utils.pushReplacement(
                      context,
                      CameraScreen(
                        videoDurationLimit:
                            GetIt.I.get<AppModel>().remainingDuration,
                      ),
                    );
                  },
                  onGallerySelected: () async {
                    var file = await ImagePicker().pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: GetIt.I.get<AppModel>().remainingDuration,
                    );
                    if (file != null)
                      Utils.pushReplacement(
                        context,
                        VideoTrimmingScreen(
                          file: File(file.path),
                        ),
                      );
                  },
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          ...GetIt.I.get<AppModel>().selectedVideosList.map(
            (e) {
              final controller = VideoPlayerController.file(e);
              return FutureBuilder(
                future: controller.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Container();
                  final chewieController = ChewieController(
                    videoPlayerController: controller,
                    autoPlay: false,
                    looping: false,
                    showControls: false,
                  );

                  chewieController.seekTo(Duration(milliseconds: 100));

                  return GestureDetector(
                    onTap: () {
                      Utils.push(context, PlayVideoScreen(video: e));
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
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
    );
  }
}

class MediaSelectionSheet extends StatelessWidget {
  final Function()? onCameraSelected;
  final Function()? onGallerySelected;

  MediaSelectionSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: Utils.getScreenWidth(context),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: onGallerySelected,
                child: Text(
                  'From Gallery',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: Utils.getScreenWidth(context),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: onCameraSelected,
                child: Text(
                  'From Camera',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
