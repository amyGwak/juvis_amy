import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juvis_prac/bluetooth/puck.dart';
import 'package:juvis_prac/widget/bluetooth_bottom_sheet.dart';
import 'measure.dart';
import 'exercise.dart';
import 'metronome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(Puck());
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/measure': (context) => const Measure(),
        '/exercise': (context) => const Exercise(),
        '/timer' : (context) => const TimerTest(),
      },
      title: 'Juvis_Ex',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toggleIcon = false;

  toggleIconState(bool value) {
    setState(() {
      toggleIcon = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            isScrollControlled: true,
            builder: (context) {
              return BluetoothBottomSheet();
            },
          );
        },
        child: Icon(
          Icons.bluetooth,
          color: Colors.black,
        ),
      ),
      body: Container(
        height: 500,
        width: double.infinity,
        color: Colors.white,
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 50, top: 150),
            child: Text("여기가 운동 메인 페이지",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 10, bottom: 10),
              textStyle: const TextStyle(fontSize: 16),
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: const Text("측정 페이지 이동"),
            onPressed: () {
              Navigator.pushNamed(context, '/measure');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                textStyle: const TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
                ),
              ),
              child: const Text("운동 페이지 이동"),
              onPressed: () {
                Navigator.pushNamed(context, '/exercise');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                textStyle: const TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
                ),
              ),
              child: const Text("타이머 테스트"),
              onPressed: () {
                Navigator.pushNamed(context, '/timer');
              },
            ),
          ),
        ]),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
