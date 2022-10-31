import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'bluetooth/puck1.dart';
import 'bluetooth/puck2.dart';


Puck1 puck1 = Puck1();
Puck2 puck2 = Puck2();

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
  bool _visible = true;
  bool isFullScreen = false;
  List<String> painPointList = ["어깨 통증", "팔이 두둑거림", "날개뼈 통증", "어지러움", "허리 통증"];

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

  void _toggle(){

    print("clicked!!");
    print("🐣🐣🐣 $_visible");

    setState((){
      _visible = !_visible;
    });
  }

  void showKeepGoingAlert () {
    List<String> menuList = ["계속", "-", "이번 동작 스킵", "측정 중단 후 다음에 할래요"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(10.0),
          title: const Text("진행 의사",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center
          ),
          content: SizedBox(
            height: 320,
            child: Column(
              children: [
                const Text("너무 힘들다면 다음 동작으로"),
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text("넘어갈까요?"),
                ),
                const Divider(),
                SizedBox(
                  width: 240,
                  height: 220,
                  child: ListView.separated(
                    itemCount: menuList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: ListTile(
                              onTap: (){
                                print("${index} 🦧🦧");
                                if(index == 0) {
                                  Navigator.pop(context);
                                }
                              },
                              leading: Text(menuList[index], textAlign: TextAlign.center),
                              selectedColor: Colors.blue,
                              textColor: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  )
                )
              ]
            )
          )
        );
      }
    );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.done) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    _toggle();
                                  },
                                  child: Stack(
                                    fit: isFullScreen ? StackFit.expand : StackFit.loose,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: _controller.value.aspectRatio,
                                        child: Container(
                                            height: 100,
                                            color: Colors.black,
                                            child: VideoPlayer(_controller)),
                                      ),
                                    ]
                                  ),
                                ),
                                  VideoProgressIndicator(_controller,
                                      allowScrubbing: false,
                                  ),
                                // Text("$position", textAlign: TextAlign.start),
                                  ValueListenableBuilder(
                                    valueListenable: _controller,
                                    builder: (context, VideoPlayerValue value, child) {
                                      //Do Something with the value.
                                      return Text(value.position.toString().split('.')[0]);
                                    },
                                  ),
                              ]
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        }
                    ),
                    Center(
                      child: Visibility(
                        visible: _visible,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white60,
                          child: IconButton(
                            onPressed: (){
                              if(_controller.value.isPlaying) {
                                _controller.pause();
                                _visible = true;
                              } else {
                                _controller.play();
                                setState((){
                                  _visible = false;
                                });
                              }
                            },
                            icon: Icon(
                                _controller.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                                size: 20,
                                color: Colors.blue),
                          )

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
                  GestureDetector(
                    onTap: (){
                      _controller.seekTo(Duration.zero);
                      _controller.play();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/retry.png', width: 16),
                          const Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text("동작 다시하기", style: TextStyle(fontSize: 12)),
                          ),
                      ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (puck1.connected && puck2.connected) ? Image.asset('images/blueDot.png', width: 20) : Image.asset('images/redDot.png', width: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(puck1.connected && puck2.connected ? "퍽 연결" : "연결 해제"),
                        ),
                        Switch(
                          value: puck1.connected && puck2.connected,
                          onChanged: (value) async {
                              await puck1.switchConnect();
                              await puck2.switchConnect();
                              setState((){});
                          },
                          activeTrackColor: Colors.grey,
                          activeColor: Colors.black,
                        )
                      ]
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("진행이 어렵다면?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                        onPressed: (){
                          //modal open
                          showKeepGoingAlert();
                        },
                        child: const Text("진행이 어렵다면 눌러주세요"),
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.only(right: 10, left: 10),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 20),
                    child: Text("지금 아픈 곳이 있나요?",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.start),
                  ),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children:<Widget>[
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: painPointList.length,
                            itemBuilder: (context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: ElevatedButton(
                                  onPressed: (){
                                    print("🐣🐣 ${painPointList[index]}");
                                    //누르면 어떻게 되는지 기획 모름
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.only(right: 10, left: 10),
                                  ),
                                  child: Text(painPointList[index]),
                                ),
                              );
                            },
                          ),
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 400,
                  color: Colors.white,
                  child: FindPuck(),
                );
              }
          );
        },
        child: const Icon(Icons.link),
        backgroundColor: Colors.grey

      )
    );
  }
}

class FindPuck extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
                children: [
                  const Text("퍽을 찾고있습니다!"),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.only(right: 10, left: 10),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("종료")
                  )
                ]
            ),
          ),
        )

    );
  }
}



