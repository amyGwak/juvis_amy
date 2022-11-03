import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

                      //PUCK1
                      if (puck.puck1.value != null)
                        ListTile(
                          leading: Icon(Icons.device_hub),
                          title: Text(puck
                              .getTranslatedDeviceName(puck.puck1.value!.name)),
                          subtitle: Text(puck.deviceStatePuck1.toString()),
                          trailing: GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {
                              puck.disconnectDevice(puck.puck1.value!);
                            },
                          ),
                        ),
                      if (puck.deviceStatePuck1.value ==
                          BluetoothDeviceState.connected)
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  puck.setSensorOnOff(
                                      true, true, puck.puck1.value!);

                                  puck.read('0004', puck.puck1.value!);
                                },
                                child: Text('주파on/센서on')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.setSensorOnOff(
                                      false, false, puck.puck1.value!);

                                  puck.read('0004', puck.puck1.value!);
                                },
                                child: Text('주파off/센서off')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.notify('0005', puck.puck1.value!, true);
                                },
                                child: Text('센서모드 on')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.notify('0005', puck.puck1.value!, false);
                                },
                                child: Text('센서모드 off')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.setFrequencyMode(
                                      1, 60, puck.puck1.value!);
                                },
                                child: Text('주파모드 설정')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.setFrequencyIntensity(
                                      16, puck.puck1.value!);
                                },
                                child: Text('주파강도-16')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.setFrequencyIntensity(
                                      0, puck.puck1.value!);
                                },
                                child: Text('주파강도-0'))
                          ],
                        ),

                      //PUCK2
                      if (puck.puck2.value != null)
                        ListTile(
                          leading: Icon(Icons.device_hub),
                          title: Text(puck
                              .getTranslatedDeviceName(puck.puck2.value!.name)),
                          subtitle: Text(puck.deviceStatePuck2.toString()),
                          trailing: GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {
                              puck.disconnectDevice(puck.puck2.value!);
                            },
                          ),
                        ),
                      if (puck.deviceStatePuck2.value ==
                          BluetoothDeviceState.connected)
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  puck.setSensorOnOff(
                                      true, true, puck.puck2.value!);
                                },
                                child: Text('주파on/센서on')),
                            ElevatedButton(
                                onPressed: () {
                                  puck.setSensorOnOff(
                                      false, false, puck.puck2.value!);
                                },
                                child: Text('주파off/센서off'))
                          ],
                        ),
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
                                  ]),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      puck.connectDevice(puck.scanList[index]);
                                    },
                                    child: Icon(Icons.connect_without_contact),
                                  ),
                                );
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
