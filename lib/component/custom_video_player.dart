import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer({required this.video, required this.onNewVideoPressed,Key? key}) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  Duration currentPosition = Duration();
  bool showControls = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeController();
  }


  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.video.path != widget.video.path) initializeController();
  }

  initializeController() async {
    currentPosition = Duration();
    videoPlayerController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoPlayerController!.initialize();

    videoPlayerController!.addListener(() {
      final currentPosition = videoPlayerController!.value.position;
      setState(() {
        this.currentPosition = currentPosition;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null) return CircularProgressIndicator();
    return AspectRatio(

      aspectRatio: videoPlayerController!.value.aspectRatio,
      child: GestureDetector(
        onTap: (){
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          children: [
            VideoPlayer(
              videoPlayerController!,
            ),
            if (showControls)
              _Controls(
                onReservePressed: onReversePressed,
                onPlayPressed: onPlayPressed,
                onForwardPressed: onForwardPressed,
                isPlaying: videoPlayerController!.value.isPlaying,
              ),
            if (showControls)
              _NewVideo(
                onPressed: widget.onNewVideoPressed,
              ),
            _SliderBottom(
                currentPosition: currentPosition,
                maxPosition: videoPlayerController!.value.duration,
                onSliderChanged: onSliderChanged)
          ],
        ),
      ),
    );
  }

  void onReversePressed() {
    final currentPosition = videoPlayerController!.value.position;

    Duration position = Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onPlayPressed() {
    // 이미 실행중이면 중지
    // 실행중이 아니면 실행
    setState(() {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.play();
      }
    });
  }

  void onForwardPressed() {
    final maxPosition = videoPlayerController!.value.duration;
    final currentPosition = videoPlayerController!.value.position;

    Duration position = maxPosition;
    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }

    videoPlayerController!.seekTo(position);
  }

  void onSliderChanged(double val) {
    currentPosition = Duration(seconds: val.toInt());
    videoPlayerController!.seekTo(
      Duration(
        seconds: val.toInt(),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReservePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls(
      {required this.onPlayPressed,
      required this.onReservePressed,
      required this.onForwardPressed,
      required this.isPlaying,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              onPressed: onReservePressed, iconData: Icons.rotate_left),
          renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.play_arrow),
          renderIconButton(
              onPressed: onForwardPressed, iconData: Icons.rotate_right),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: onPressed,
          iconSize: 30.0,
          color: Colors.white,
          icon: Icon(
            iconData,
          ),
        ),
      ],
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.photo_camera_back,
          color: Colors.white,
        ),
        iconSize: 30.0,
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom(
      {required this.currentPosition,
      required this.maxPosition,
      required this.onSliderChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Slider(
                max: maxPosition.inSeconds.toDouble(),
                min: 0,
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
              ),
            ),
            Text(
              '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
