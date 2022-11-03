import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'bluetooth/puck1.dart';
import 'bluetooth/puck2.dart';
import 'popup.dart';


Puck1 puck1 = Puck1();
Puck2 puck2 = Puck2();

class Measure extends StatefulWidget {
  const Measure({Key? key}) : super(key:key);

  @override
  _Measure createState() => _Measure();
}

class _Measure extends State<Measure> {
  // late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  //다음 영상을 초기화할 컨트롤러를 미리 생성
  late VideoPlayerController _nextController;
  late Future<void> _initializeNextVideoPlayerFuture;


  int currentVideoOrder = 0;
  int currentCount = 0;
  bool puckConnected = false;
  bool _visible = true;
  bool isFullScreen = false;
  bool isCurrentVideoEnd = false;
  bool isPlayStarted = false;
  List<String> painPointList = ["어깨 통증", "팔이 두둑거림", "날개뼈 통증", "어지러움", "허리 통증"];

  late VoidCallback listener;
  String defaultStream = "https://amytest2.s3.ap-northeast-2.amazonaws.com/KakaoTalk_Video_2022-10-26-19-00-51.mp4";
  String secondStream = "https://amytest2.s3.ap-northeast-2.amazonaws.com/videotest.mp4";
  String thirdStream = "https://amytest2.s3.ap-northeast-2.amazonaws.com/test3.mp4";

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  late Timer _timer;

  //운동 영상
  Set<String> streamUrl = {
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test4.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test3.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/5%E1%84%8E%E1%85%A9.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/KakaoTalk_Video_2022-10-26-19-00-51.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/videotest.mp4"
  };

  List<int> videoOrder = [];

  // 영상 교체 토글도 만들어야 함

  // 대체 영상 1개 -> 얘네 controller도 만들어야함
  String alterUrl = "";

  // break 영상 1개 -> 얘네 controller도 만들어야함
  String breakUrl = "";


  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100));

    if(streamUrl.length > 0) {
      _initController(0).then((_) {
        _playController(0);
        _timer = Timer.periodic(Duration(seconds: 2), (timer) {
          setState((){
            currentCount++;
          });
        });
      });
    }
    if(streamUrl.length > 1) {
      _initController(1).whenComplete(() => _lock = false);
    }

    videoOrder = List<int>.generate(streamUrl.length + 1, (i) => i + 1);

  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  VideoPlayerController _controller(int index) {
    return _controllers[streamUrl.elementAt(index)]!;
  }

  VoidCallback _listenerSpawner(index) {
    return () {
      int? duration = _controller(index).value.duration.inSeconds;
      int? position = _controller(index).value.position.inSeconds;
      int? buffer = _controller(index).value.buffered.last.end.inSeconds;

      setState((){
        if(duration <= position) {
          _position = 0;
          return;
        }
        _position = position / duration;
        _buffer = buffer / duration;
      });

      if(duration - position < 1) {
        if(index < streamUrl.length - 1) {
          _nextVideo();
          currentCount = 0;
        }
      }
    };
  }



  Future<void> _initController(int index) async {
    var controller = VideoPlayerController.network(streamUrl.elementAt(index));
    _controllers[streamUrl.elementAt(index)] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(streamUrl.elementAt(index));
    _listeners.remove(index);
  }

  void _stopController(int index) {
    _controller(index).removeListener(_listeners[index]!);
    _controller(index).pause();
    _controller(index).seekTo(Duration.zero);
  }


  void _playController(int index) async {
    if(!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner(index);
    }
    _controller(index).addListener(_listeners[index]!);
    await _controller(index).play();
    setState((){});

  }

  void _nextVideo () async {
    if(_lock || currentVideoOrder == streamUrl.length - 1) {
      return;
    }
    _lock = true;
    _stopController(currentVideoOrder);

    if(currentVideoOrder - 1 >= 0) {
      _removeController(currentVideoOrder -1);
    }

    _playController(++currentVideoOrder);

    if(currentVideoOrder == streamUrl.length - 1){
      _lock = false;
    } else {
      _initController(currentVideoOrder + 1).whenComplete(() => _lock = false);
    }


  }


  void _toggle(){
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
                    // FutureBuilder(
                        // future: _initializeVideoPlayerFuture_controller(index),
                        // builder: (context, snapshot) {
                          // if(snapshot.connectionState == ConnectionState.done) {
                            Column(
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
                                          aspectRatio: _controller(currentVideoOrder).value.aspectRatio,
                                          child: Container(
                                            // height: 100,
                                              color: Colors.black,
                                              child: VideoPlayer(_controller(currentVideoOrder))),
                                        ),
                                      ) :
                                      AspectRatio(
                                        aspectRatio: _controller(currentVideoOrder).value.aspectRatio,
                                        child: Container(
                                            // height: 100,
                                            color: Colors.black,
                                            child: VideoPlayer(_controller(currentVideoOrder))),
                                      ),
                                    ]
                                  ),
                                ),
                                  VideoProgressIndicator(
                                    _controller(currentVideoOrder),
                                      allowScrubbing: false,
                                  ),
                                // Text("$position", textAlign: TextAlign.start),
                                  ValueListenableBuilder(
                                    valueListenable: _controller(currentVideoOrder),
                                    builder: (context, VideoPlayerValue value, child) {
                                      //Do Something with the value.
                                      return Text(value.position.toString().split('.')[0]);
                                    },
                                  ),
                              ]
                            ),
                          // }
                          // else {
                          //   return const Center(child: CircularProgressIndicator());
                          // }
                        // }
                    // ),
                    Center(
                      child: Visibility(
                        visible: _visible,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white60,
                          child: IconButton(
                            onPressed: (){
                              if(_controller(currentVideoOrder).value.isPlaying) {
                                _controller(currentVideoOrder).pause();
                                _timer.cancel();
                                _visible = true;
                              } else {
                                _controller(currentVideoOrder).play();
                                setState((){
                                  _visible = false;
                                  if(!_timer.isActive){
                                    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
                                      setState((){
                                        currentCount++;
                                      });
                                    });
                                  }
                                });
                              }
                            },
                            icon: Icon(
                                _controller(currentVideoOrder).value.isPlaying == true ? Icons.pause : Icons.play_arrow,
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
                      for(num i=1; i<_controller(currentVideoOrder).value.duration.inSeconds/2 + 1; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextButton(
                              onPressed: () {
                                  print("🌼🌼$i is clicked");
                                  setState((){
                                    currentCount = int.parse("$i");
                                  });
                              },
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 16),
                                  backgroundColor: currentCount == int.parse("$i") ? Colors.orangeAccent : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100), // <-- Radius
                                ),
                              ),
                                  child: Text("$i",
                                      style: TextStyle(
                                          color: currentCount == int.parse("$i") ? Colors.black : Colors.grey,
                                      )),
                              ),
                        ),

                      ]
                    )
                  ),
                  GestureDetector(
                    onTap: (){
                      _controller(currentVideoOrder).seekTo(Duration.zero);
                      _controller(currentVideoOrder).play();
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 320,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            //측정 완료 팝업 띄우기기
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const ShowLastPopup(route: "/");
                                }
                            );
                          },
                          child: const Text("측정 완료하기!"),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
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



