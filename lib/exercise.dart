import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'bluetooth/puck1.dart';
import 'bluetooth/puck2.dart';

Puck1 puck1 = Puck1();
Puck2 puck2 = Puck2();

class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _Exercise createState() => _Exercise();
}

class _Exercise extends State<Exercise> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  List<int> videoOrder = List<int>.generate(11, (i) => i + 1);
  int currentVideoOrder = 1;
  bool puckConnected = false;
  bool _visible = true;
  bool isFullScreen = false;
  bool isWearingWear = false;
  List<String> painPointList = ["어깨 통증", "팔이 두둑거림", "날개뼈 통증", "어지러움", "허리 통증"];

  String defaultStream = "https://amytest2.s3.ap-northeast-2.amazonaws.com/KakaoTalk_Video_2022-10-26-19-00-51.mp4";
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100));
    _controller = VideoPlayerController.network(defaultStream);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  Future<void> changeVideo(String videoPath) async {
     _controller = VideoPlayerController.network(videoPath);
     _controller.addListener((){

     });
  }

  void showKeepGoingAlert () {
    List<String> menuList = ["계속", "아파", "힘들어", "숨차"];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              title: const Text("진행 의사",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text("왜 진행이 어려운가요?"),
                    ),
                    const Divider(),
                    SizedBox(
                        width: 240,
                        height: 250,
                        child: ListView.separated(
                          itemCount: menuList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
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
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text("프로그램"),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Stack(alignment: Alignment.center, children: [
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
                                  children: [
                                    isFullScreen ?
                                    RotatedBox(
                                      quarterTurns: 1,
                                      child: AspectRatio(
                                        aspectRatio: _controller.value.aspectRatio,
                                        child: Container(
                                          // height: 100,
                                            color: Colors.black,
                                            child: VideoPlayer(_controller)),
                                      ),
                                    ) :
                                    AspectRatio(
                                      aspectRatio: _controller.value.aspectRatio,
                                      child: Container(
                                        // height: 100,
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
                        onPressed: () {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                            _visible = true;
                          } else {
                            _controller.play();
                            setState(() {
                              _visible = false;
                            });
                          }
                        },
                        icon: Icon(
                            _controller.value.isPlaying == true
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 20,
                            color: Colors.blue),
                      )),
                ),
              ),
              Positioned(
                top: 15,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen),
                  color: Colors.white,
                  iconSize: 25,
                  onPressed: () {
                    //full screen horizontal
                    setState(() {
                      isFullScreen = !isFullScreen;
                    });
                  },
                ),
              ),
              Positioned(
                top: 45,
                child: Switch(
                  activeColor: Colors.white,
                  value: true,
                  onChanged: (bool value) {

                  },
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text("스쿼트", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("에이미가 싫어하는 코어에 좋은 하체 동작", textAlign: TextAlign.start, style: TextStyle(fontSize: 14))),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      _controller.seekTo(Duration.zero);
                      _controller.play();
                    },
                    child: Row(children: [
                      Image.asset("images/retry.png"),
                      const Text("동작 다시하기")
                    ]),
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey,
                    ),
                  onPressed: () {
                    showKeepGoingAlert();
                  },
                  child:
                    const Text("진행이 어려워요")
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 260,
                    child: const Text("이 운동은 RT웨어를 착용하고 운동하시면 더 좋습니다. 더 살이 많이 빠질거에요 쭊쭉...",
                        // textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.grey)
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20, left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("이 운동의 소모 칼로리"),
                      Text("기본: 120Kcal", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("착용시: 180Kcal", style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xffBC74F5))),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 30),
              child: Row(
                children: [
                  const Text("RT웨어 착용"),
                  Switch(
                    activeColor: Colors.black,
                    onChanged: (value){
                      setState((){
                        isWearingWear = !isWearingWear;
                      });
                    },
                    value: isWearingWear,
                  )
                ]
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 320,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("운동 완료!"),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        )));
  }
}
