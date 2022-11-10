import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juvis_prac/bluetooth/puck.dart';
import 'package:juvis_prac/widget/bluetooth_bottom_sheet.dart';
import 'video/measure.dart';
import 'video/exercise.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  @override
  void initState(){
    super.initState();

    // login();

  }

  Future<void> login () async {
    Uri url = Uri.parse('http://j-test.nonegolab.com/api/login');
    final response = await http.post(url, body: json.encode({'userSn': "1", 'pToken': "111" }),
        headers: {
          "Accept": "application/json;charset=UTF-8",
          "content-type":"application/json"
        }
    );

    print("🐸🐸response ${jsonDecode(response.body)}");

    var res = jsonDecode(response.body);
    String token = res["result"]["token"];
    print("token, ${token}");
    final SharedPreferences prefs = await _prefs;
    prefs.setString('token', token).then((bool success){
      print('success ${success}');
    });

  }


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
              child: const Text("로그인"),
              onPressed: () async{
                await login();
              },
            ),
          ),
        ]),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
