import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';


class Measure extends StatefulWidget {
  const Measure({Key? key}) : super(key:key);

  @override
  _Measure createState() => _Measure();
}

class _Measure extends State<Measure> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  List<int> videoOrder = List<int>.generate(11, (i) => i + 1);
  int currentVideoOrder = 1;
  bool puckConnected = false;


  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100));
    _controller = VideoPlayerController.network(
        "https://amytest2.s3.ap-northeast-2.amazonaws.com/KakaoTalk_Video_2022-10-26-19-00-51.mp4");
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        }
        ),
        title: Text("측정"),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Container(
                          height: 100,
                          color: Colors.black,
                          child: VideoPlayer(_controller)),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (){},
                ),
                Text("스쿼트 1/3 SET", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: (){},
                )
              ]
            ),
            Text("에이미는 스쿼트가 싫어요!!"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for(num i=1; i<12; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextButton(
                            onPressed: () {
                                print("🌼🌼$i is clicked");
                                setState((){
                                  currentVideoOrder = int.parse("$i");
                                });
                            },
                            style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 16),
                                backgroundColor: currentVideoOrder == int.parse("$i") ? Colors.orangeAccent : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100), // <-- Radius
                              ),
                            ),
                                child: Text("$i",
                                    style: TextStyle(
                                        color: currentVideoOrder == int.parse("$i") ? Colors.black : Colors.grey,
                                    )),
                            ),
                      ),

                ]
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    iconSize: 16,
                    onPressed: (){},
                  ),
                  Text("동작 다시하기", style: TextStyle(fontSize: 12)),
              ]
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: puckConnected ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    onPressed: (){},
                  ),
                  Text(puckConnected ? "퍽 연결" : "연결 해제"),
                  Switch(
                    value: puckConnected,
                    onChanged: (value) async {
                      setState((){
                        puckConnected = !puckConnected;
                      });
                    },
                    activeTrackColor: Colors.grey,
                    activeColor: Colors.black,
                  )
                ]
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text("진행이 어렵다면?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            ),
            ElevatedButton(
                onPressed: (){
                  //modal open
                },
                child: const Text("진행이 어렵다면 눌러주세요")
            )
          ],
        ),
      )
    );
  }
}