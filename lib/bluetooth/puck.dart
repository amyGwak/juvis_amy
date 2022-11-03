import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';
import 'package:juvis_prac/bluetooth/puck1.dart';

const PUCK1 = 'J-1';
const PUCK2 = 'J-2';

class Puck extends GetxController {
  Puck._privateConstructor(); //private 생성자
  static final Puck _instance =
      Puck._privateConstructor(); //singleton 인스턴스를 변수에 할당

  factory Puck() {
    return _instance; //Puck 호출시 _instance 변수 반환
  }
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  RxList<BluetoothDevice> scanList = <BluetoothDevice>[].obs;
  RxBool scanning = false.obs;

//PUCK1

  //flutter_blue_plus용 퍽 연결상태 state
  Rx<BluetoothDeviceState> connectStatePuck1 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);

  //임의로 만든 퍽 연결상태 state
  Rx<BluetoothDeviceState> deviceStatePuck1 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  Rx<BluetoothDevice?> puck1 = Rx<BluetoothDevice?>(null);
  BluetoothService? servicePuck1;
  BluetoothCharacteristic? charState1; //0001 특성
  BluetoothCharacteristic? charFreq1; //0002 주파모드
  BluetoothCharacteristic? charFreqLevel1; //0003 주파강도
  BluetoothCharacteristic? blueSensorOn1; //0004 센서on/off
  BluetoothCharacteristic? blueSensorMode1; //0005 센서모드
  BluetoothCharacteristic? blueBattery1; //0006 배터리
  BluetoothCharacteristic? blueMotionErr1; //0007 모션에러

//PUCK2

  //flutter_blue_plus용 퍽 연결상태 state
  Rx<BluetoothDeviceState> connectStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  //임의로 만든 퍽 연결상태 state
  Rx<BluetoothDeviceState> deviceStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  Rx<BluetoothDevice?> puck2 = Rx<BluetoothDevice?>(null);
  BluetoothService? servicePuck2;
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

  Future<List> scan() async {
    scanning.value = true;
    await flutterBlue.startScan(timeout: Duration(seconds: 2));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == PUCK1 || r.device.name == PUCK2) {
          if (scanList.every((device) => device.id != r.device.id)) {
            scanList.value = [...scanList, r.device];
          }
        }
      }
    });
    await flutterBlue.stopScan();
    scanning.value = false;

    return scanList;
  }

  void stopScan() async {
    //타이밍 이슈
    await flutterBlue.stopScan();
    scanList.value = [];
    scanning.value = false;
  }

  String getTranslatedDeviceName(String name) {
    switch (name) {
      case PUCK1:
        return '상의용';
      case PUCK2:
        return '하의용';
      default:
        return '';
    }
  }

  void connectDevice(BluetoothDevice device) async {
    await device.connect();

    //Puck1
    if (device.name == PUCK1) {
      deviceStatePuck1.value = BluetoothDeviceState.connecting;

      device.state.listen((state) {
        connectStatePuck1.value = state; //puck1의 상태 데이터 저장
        switch (state) {
          case BluetoothDeviceState.connecting:
            print('🔥🔥connecting');
            puck1.value = device;
            break;
          case BluetoothDeviceState.connected:
            print('🔥🔥connected');
            deviceStatePuck1.value = BluetoothDeviceState.connected;
            puck1.value = device;
            setService(device);
            // Todo ::: 스캔 리스트에서 연결중인 퍽 삭제
            break;
          case BluetoothDeviceState.disconnecting:
            print('🔥🔥disconnecting');
            break;
          case BluetoothDeviceState.disconnected:
            print('🔥🔥disconnected');
            deviceStatePuck1.value = BluetoothDeviceState.disconnected;
            connectStatePuck1.value = BluetoothDeviceState.disconnected;
            puck1.value = null;
            servicePuck1 = null;

            break;
          default:
        }
      });
    } else if (device.name == PUCK2) {
      deviceStatePuck2.value = BluetoothDeviceState.connecting;

      device.state.listen((state) {
        connectStatePuck2.value = state; //puck1의 상태 데이터 저장
        switch (state) {
          case BluetoothDeviceState.connecting:
            print('🐳🐳connecting');
            puck2.value = device;
            break;
          case BluetoothDeviceState.connected:
            print('🐳🐳connected');
            deviceStatePuck2.value = BluetoothDeviceState.connected;
            puck2.value = device;
            setService(device);
            // Todo ::: 스캔 리스트에서 연결중인 퍽 삭제
            break;
          case BluetoothDeviceState.disconnecting:
            print('🐳🐳disconnecting');
            break;
          case BluetoothDeviceState.disconnected:
            print('🐳🐳disconnected');
            deviceStatePuck2.value = BluetoothDeviceState.disconnected;
            connectStatePuck2.value = BluetoothDeviceState.disconnected;
            puck2.value = null;
            servicePuck2 = null;
            break;
          default:
        }
      });
    }
  }

  void disconnectDevice(BluetoothDevice device) {
    device.disconnect();
  }

  void setService(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    if (device.name == PUCK1)
      servicePuck1 = services.firstWhere(
          (s) => s.uuid.toString().toUpperCase().substring(4, 8) == '4A56');
    else if (device.name == PUCK2)
      servicePuck2 = services.firstWhere(
          (s) => s.uuid.toString().toUpperCase().substring(4, 8) == '4A56');
  }
}
