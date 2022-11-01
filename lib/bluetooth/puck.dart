import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';

const PUCK1 = 'J-1';
const PUCK2 = 'J-2';

class Puck extends GetxController {
  Puck._privateConstructor(); //private 생성자
  static final Puck _instance =
      Puck._privateConstructor(); //singleton 인스턴스를 변수에 할당

  factory Puck() {
    return _instance; //Puck 호출시 _instance 변수 반환
  }

  RxList<BluetoothDevice> scanList = <BluetoothDevice>[].obs;
  RxBool scanning = false.obs;

//PUCK1
  BluetoothDevice? puck1;
  BluetoothCharacteristic? charState1; //0001 특성
  BluetoothCharacteristic? charFreq1; //0002 주파모드
  BluetoothCharacteristic? charFreqLevel1; //0003 주파강도
  BluetoothCharacteristic? blueSensorOn1; //0004 센서on/off
  BluetoothCharacteristic? blueSensorMode1; //0005 센서모드
  BluetoothCharacteristic? blueBattery1; //0006 배터리
  BluetoothCharacteristic? blueMotionErr1; //0007 모션에러

//PUCK2
  BluetoothDevice? puck2;
  BluetoothCharacteristic? charState2; //0001 특성
  BluetoothCharacteristic? charFreq2; //0002 주파모드
  BluetoothCharacteristic? charFreqLevel2; //0003 주파강도
  BluetoothCharacteristic? blueSensorOn2; //0004 센서on/off
  BluetoothCharacteristic? blueSensorMode2; //0005 센서모드
  BluetoothCharacteristic? blueBattery2; //0006 배터리
  BluetoothCharacteristic? blueMotionErr2; //0007 모션에러

  List<String> state = [];
  List<int> frequency = [];
  List<int> frequencyLevel = [];
  int sensorValue = 0;
  List<int> sensorMode = [];
  bool isSensorOn = false;
  bool isFrequencyOn = false;
  String battery = '0%';

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  Future<List> scan() async {
    scanning.value = true;
    await flutterBlue.startScan(timeout: Duration(seconds: 2));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == PUCK1 || r.device.name == PUCK2) {
          if (scanList.value.every((device) => device.id != r.device.id)) {
            scanList.value.add(r.device);
            [...scanList.value, r.device];
          }
        }
      }
    });
    await flutterBlue.stopScan();
    scanning.value = false;

    return scanList.value;
  }
}
