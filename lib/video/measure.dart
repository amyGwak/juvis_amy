import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../bluetooth/puck1.dart';
import '../bluetooth/puck2.dart';
import '../popup.dart';
import 'exVideo.dart';


Puck1 puck1 = Puck1();
Puck2 puck2 = Puck2();

class Measure extends StatefulWidget {
  const Measure({Key? key}) : super(key:key);

  @override
  _Measure createState() => _Measure();
}

class _Measure extends State<Measure> {

  late Duration currentPosition;
  int currentVideoOrder = 0;
  int currentCount = 0;
  bool _visible = true;
  List<String> painPointList = ["어깨 통증", "팔이 두둑거림", "날개뼈 통증", "어지러움", "허리 통증"];

  bool isMetronomeMode = false;

  String curMode = "ex";
  String prevMode = "";

  //영상 관련
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  final Map<String, VideoPlayerController> _metronomeControllers = {};

  bool _lock = true;
  late Timer _timer;

  // 운동 영상
  Set<String> streamUrl = {
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test3.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test4.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/%E1%84%92%E1%85%B2%E1%84%89%E1%85%B5%E1%86%A8_10%E1%84%8E%E1%85%A9.mp4",
        "https://amytest2.s3.ap-northeast-2.amazonaws.com/videotest.mp4",
  };

  // 본운동(human count 영상)
  Set<String> metronomeUrl = {
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test4.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/test3.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/%E1%84%92%E1%85%B2%E1%84%89%E1%85%B5%E1%86%A8_10%E1%84%8E%E1%85%A9.mp4",
    "https://amytest2.s3.ap-northeast-2.amazonaws.com/videotest.mp4",
  };


  //Todo: 1) 순서 나열(api 요청 포함), 2) 함수는 목적별로 분리, 3) 분기 타야하는 것들은 어쩔 수 없어, 4) 모드는 2개(isMetronome T/F)


  // 영상 재생 순서

  // initController (20개 컨트롤러 준비) - 모든 controller 전부
  // listenController (준비된 컨트롤러에 listener 구독) - controller 별로 다르다. 다음 영상 준비 함수 필
  // playController (재생시킨다) - play()만
  // stopController (중지됬을 때) - pause(), 리스너 구독을 여기서 해제할 필요 있나? 삭제하면..?
  // removeController (재생이 끝난 -2번째 비디오를 삭제한다) - 두번째 영상전꺼를 아예 controllers에서 삭제, dispose
  // reset 하는 함수 ( 모든 controller dispose, 최상위 dispose에서 )



  // Map<String, Map<String, String>> controllers = {
  //   "ex": { "url1": "111","url2": "222" },
  //   "ex2": { "url2": "333" },
  //   "alter": { "url": "444" },
  //   "break": { "url": "555" }
  // };





  @override
  void initState() {
    super.initState();

    if (mounted && streamUrl.length > 0) {
      _initFirstController().then((_) {
        _listenController(0);
        _playController(0);
        startTimer();
        _lock = false;
      });
    }

    // if (streamUrl.length > 1) {
    //   _initNextController(1).whenComplete(() => );
    // }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    // 마지막 controller와 그 이전 controller 지워주기
    _controllers[streamUrl.elementAt(currentVideoOrder)]?.dispose();
    _controllers[streamUrl.elementAt(currentVideoOrder - 1)]?.dispose();
    _timer.cancel();

    super.dispose();
  }

  /// 대체 영상과 break 영상은 지금 본 운동 종류가 뭐냐에 따라 복귀하는 영상이 달라진다.
  /// 즉 본 운동 모드와 대체/break 영상의 depth는 다를것이다.


  VideoPlayerController _metronomeController(int index) {
    return _metronomeControllers[metronomeUrl.elementAt(index)]!;
  }

  VideoPlayerController getCurrentController (index) {
    return _controllers[streamUrl.elementAt(index)]!;
  }



  void playHandler () {
    var controller = getCurrentController(currentVideoOrder);

    if(controller.value.isPlaying) {
      controller.pause();
      _timer.cancel();
      _visible = true;
    } else {
      controller.play();
      setState((){
        _visible = false;
        if(!_timer.isActive){
          startTimer();
        }
      });
    }

  }

  void startTimer () {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      var controller =  getCurrentController(currentVideoOrder);
      setState((){
        if(controller.value.isPlaying) {
          currentCount++;
        }
      });
    });
  }



  VoidCallback _listenerSpawner(index) {

    var controller = getCurrentController(index);

    return () {

      int? duration;
      int? position;

      duration = controller.value.duration.inSeconds;
      position = controller.value.position.inSeconds;

      int gap = duration - position;


      setState((){
        if(duration! - position! < 2) {
          // 0 이거나 음수일 때 = 영상 재생 중일 때
          if(index < streamUrl.length - 1) {
            // 영상이 마지막 영상이 아닐때, 다음 비디오로 넘어간다.
            _nextVideo();
          } else {
            // 마지막 영상이면 운동 완료 페이지로 이동시켜줘야 함
            // 기획에 따라 재정비
          }
        }
      });
    };
  }


  // 처음에 딱 한번만 초기화(1개 컨트롤러)
  Future<void> _initFirstController () async {
    _controllers[streamUrl.elementAt(0)] = VideoPlayerController.network(streamUrl.elementAt(0));
    await _controllers[streamUrl.elementAt(0)]?.initialize();

  }

  Future<void> _initNextController(int index) async {
    // index 로 넘어온 것들만 초기화
    var controller = VideoPlayerController.network(streamUrl.elementAt(index));
    _controllers[streamUrl.elementAt(index)] = controller;
    await controller.initialize();
  }



  // controller 아예 삭제
  void _removeController() {
    var index = currentVideoOrder - 2;
    var controller = getCurrentController(index);

      controller.dispose();
      _controllers.remove(streamUrl.elementAt(index));
      _listeners.remove(index);
    }


  void _stopController(int index) {
    var controller = getCurrentController(index);

    controller.removeListener(_listeners[index]!);
    controller.pause();
    controller.seekTo(Duration.zero);

  }


  Future<void> _listenController(int index) async {

    var controller = getCurrentController(index);

    if(!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner(index);
    }
    controller.addListener(_listeners[index]!);
}


  //Todo: 해당 함수는 다음 영상을 준비 해주는 것만 하기
  void _nextVideo () async {
    if(_lock || currentVideoOrder == streamUrl.length - 1) {
      //마지막 비디오라면
      return;
    }

    _lock = true;

    //Todo: stop & remove 를 묶는 함수를 만들어서 nextVideo 전에 호출
    _stopController(currentVideoOrder);

    if(currentVideoOrder >= 2) {
      // 첫번째, 두번째 비디오빼고, 뒤에서 세번째 비디오부터 지운다.
      _removeController();
    }


    if(currentVideoOrder == streamUrl.length - 1){
      //마지막 비디오면..
      _lock = false;
    } else {
      //마지막 비디오 아니면, 다음 비디오 controller 준비한다.
      await _initNextController(currentVideoOrder + 1);
      await _listenController(currentVideoOrder + 1);
      await _playController(currentVideoOrder + 1);
      _lock = false;

    }

    setState((){
      currentVideoOrder += 1;
    });

  }

  void removePrevController () {
    if(currentVideoOrder == streamUrl.length - 1) {
      //something happen
    }
  }

  Future<void> _playController(int index) async {
    var controller = getCurrentController(index);

    setState((){
      currentCount = 0;
    });

    await controller.play();
  }

  void changeVideo() {
    //본 운동 카운트 바꾸는 함수
    //
    // if(curMode == "humanCount") {
    //   _metronomeController(currentVideoOrder).pause();
    //   currentPosition = _metronomeController(currentVideoOrder).value.position;
    //
    //   _controller(currentVideoOrder).seekTo(currentPosition);
    //   setState((){});
    //   _controller(currentVideoOrder).play();
    //
    // } else {
    //   _controller(currentVideoOrder).pause();
    //   currentPosition = _controller(currentVideoOrder).value.position;
    //
    //   _metronomeController(currentVideoOrder).seekTo(currentPosition);
    //   setState((){});
    //   _metronomeController(currentVideoOrder).play();
    // }
    //
    // setState(() {
    //   curMode = curMode == "ex" ? "humanCount" : "ex";
    // });
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
        title: const Text("측정"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: Center(
            child: Column(
              children: <Widget>[
                ExVideo(controller: getCurrentController(currentVideoOrder), changeVideo: changeVideo, currentVideoOrder: currentVideoOrder,
                    curMode: curMode, visible: _visible, playHandler: playHandler,
                    toggle: _toggle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left),
                      onPressed: (){},
                    ),
                    const Text("스쿼트 1/3 SET", style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right),
                      onPressed: (){},
                    )
                  ]
                ),
                const Text("에이미는 월요일이 싫어요!!"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: [
                      for(num i=1; i< getCurrentController(currentVideoOrder).value.duration.inSeconds/2.round() + 1; i++)
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
                      if(isMetronomeMode) {
                        _metronomeController(currentVideoOrder).seekTo(Duration.zero);
                        _metronomeController(currentVideoOrder).play();
                      } else {
                        getCurrentController(currentVideoOrder).seekTo(Duration.zero);
                        getCurrentController(currentVideoOrder).play();
                      }

                      // 타이머 다시 리셋
                      currentCount = 0;

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/retry.png', width: 16),
                          const Padding(
                            padding: EdgeInsets.only(left: 3),
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
                  // SizedBox(
                  //   height: 50,
                  //   child: Row(
                  //     children:<Widget>[
                  //       Expanded(
                  //         child: ListView.builder(
                  //           shrinkWrap: true,
                  //           // physics: const NeverScrollableScrollPhysics(),
                  //           scrollDirection: Axis.horizontal,
                  //           itemCount: painPointList.length,
                  //           itemBuilder: (context, int index) {
                  //             return Padding(
                  //               padding: const EdgeInsets.only(right: 20),
                  //               child: ElevatedButton(
                  //                 onPressed: (){
                  //                   print("🐣🐣 ${painPointList[index]}");
                  //                   //누르면 어떻게 되는지 기획 모름
                  //                 },
                  //                 style: ElevatedButton.styleFrom(
                  //                   backgroundColor: Colors.white,
                  //                   foregroundColor: Colors.black,
                  //                   padding: const EdgeInsets.only(right: 10, left: 10),
                  //                 ),
                  //                 child: Text(painPointList[index]),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       )
                  //     ]
                  //   ),
                  // ),
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



