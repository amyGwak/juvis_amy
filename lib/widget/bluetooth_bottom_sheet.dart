import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juvis_prac/bluetooth/puck.dart';

class BluetoothBottomSheet extends StatefulWidget {
  BluetoothBottomSheet({super.key});

  @override
  _BluetoothBottomSheetState createState() => _BluetoothBottomSheetState();
}

class _BluetoothBottomSheetState extends State<BluetoothBottomSheet> {
  final puck = Get.find<Puck>();

  void closeModal() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              ListTile(
                  trailing: TextButton(
                    child: Text(
                      '문의하기',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                  leading: GestureDetector(
                    onTap: closeModal,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  )),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 기기 찾기',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'LED 점멸 여부로 내 기기 확인 후 등록을 진행하세요',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      puck.scanning.value == true
                          ? OutlinedButton(
                              onPressed: () {
                                puck.stopScan();
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(9999, 40),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pause,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    '찾는중',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ))
                          : ElevatedButton(
                              onPressed: () async {
                                puck.scan();
                              },
                              child: Text('찾기'),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(9999, 40),
                                  backgroundColor: Colors.black),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      Heading(title: '등록된 기기'),
                      Heading(title: '연결 가능한 기기'),
                      SizedBox(
                          height: 300,
                          child: ListView.builder(
                              itemCount: puck.scanList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    leading: Icon(Icons.device_hub),
                                    title: Text(puck.getTranslatedDeviceName(
                                        puck.scanList[index].name)),
                                    subtitle: Column(children: <Widget>[
                                      Text(puck.scanList[index].name),
                                    ]));
                              })),
                    ]),
              ))
            ],
          ),
        ));
  }
}

class Heading extends StatelessWidget {
  String title = '제목';
  Heading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9999,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}
