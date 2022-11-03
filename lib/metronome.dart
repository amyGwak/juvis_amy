import 'package:flutter/material.dart';
import 'dart:async';



class TimerTest extends StatefulWidget {
  const TimerTest({Key? key}) : super(key:key);

  @override
  _TimerTest createState() => _TimerTest();
}


class _TimerTest extends State<TimerTest> {

  late Timer _timer;
  int _timerCount = 0;

  void startTimer(){
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState((){
        _timerCount++;
      });
    });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: OutlinedButton(
                onPressed: (){
                  startTimer();
                },
                child: const Text("메트로놈 시작"),
              ),
            ),
            Text("$_timerCount"),
          ]
        )
      ),
    );
  }

}