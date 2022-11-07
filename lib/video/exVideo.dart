import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';


class ExVideo extends StatefulWidget {

  const ExVideo({super.key,
    required this.controller,
    required this.visible,
    required this.playHandler,
    required this.toggle,
    required this.currentVideoOrder,
  });

  final VideoPlayerController controller;
  final bool visible;
  final VoidCallback playHandler;
  final VoidCallback toggle;
  final int currentVideoOrder;

  @override
  _ExVideo createState() => _ExVideo();
}

class _ExVideo extends State<ExVideo> {

  bool isFullScreen = false;


  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
          alignment: Alignment.center,
          children: [
            Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      widget.toggle();
                    },
                    child: Stack(
                        children: [
                          isFullScreen ?
                          RotatedBox(
                            quarterTurns: 1,
                            child: AspectRatio(
                              aspectRatio: widget.controller.value.aspectRatio,
                              child: Container(
                                  height: 100,
                                  color: Colors.black,
                                  child: VideoPlayer(widget.controller)
                            ),
                          )
                          )
                            :
                          AspectRatio(
                            aspectRatio: widget.controller.value.aspectRatio,
                            child: Container(
                                height: 100,
                                color: Colors.black,
                                child: VideoPlayer(widget.controller)
                            ),
                          ),
                        ]
                    ),
                  ),
                  // VideoProgressIndicator(
                  //   widget.controller,
                  //   allowScrubbing: false,
                  // ),
                  // Text("$position", textAlign: TextAlign.start),
                  ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (context, VideoPlayerValue value, child) {
                      //Do Something with the value.
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(value.position.toString().split('.')[0]),
                            Text(" / ${value.duration.toString().split('.')[0]}")
                          ],
                        ),
                      );
                    },
                  ),
                ]
            ),

            Center(
              child: Visibility(
                visible: widget.visible,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white60,
                    child: IconButton(
                      icon: Icon(
                          widget.controller.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                          size: 20,
                          color: Colors.blue),
                      onPressed: (){
                        widget.playHandler();
                        },
                ),
              ),
            ),
            ),
            Positioned(
              top: 30,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.fullscreen),
                color: Colors.white,
                iconSize: 25,
                onPressed: (){
                  //full screen horizontal
                  setState((){
                    isFullScreen = !isFullScreen;
                  });
                },
              ),
            ),
          ]
    );
  }

}