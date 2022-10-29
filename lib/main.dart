import 'package:flutter/material.dart';
import 'measure.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/measure': (context) => const Measure(),
      },
      title: 'Juvis_Ex',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text("여기가 운동 메인 페이지", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                  textStyle: const TextStyle(fontSize: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // <-- Radius
                  ),
                ),
                child: const Text("측정 페이지 이동"),
                onPressed:() {
                  Navigator.pushNamed(context, '/measure');
                },
              ),
            ]
          ),
        ),
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
