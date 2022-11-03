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
  Map<String, BluetoothCharacteristic?> charPuck1 = {
    "0001": null, //state
    "0002": null, //주파모드
    "0003": null, //주파강도
    "0004": null, //센서on/off
    "0005": null, //센서모드
    "0006": null, //배터리
    "0007": null, //모션에러
  };

  RxList<int> sensorModePuck1 = <int>[].obs;

//PUCK2

  //flutter_blue_plus용 퍽 연결상태 state
  Rx<BluetoothDeviceState> connectStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  //임의로 만든 퍽 연결상태 state
  Rx<BluetoothDeviceState> deviceStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  Rx<BluetoothDevice?> puck2 = Rx<BluetoothDevice?>(null);
  BluetoothService? servicePuck2;
  Map<String, BluetoothCharacteristic?> charUuidPuck2 = {
    "0001": null, //state
    "0002": null, //주파모드
    "0003": null, //주파강도
    "0004": null, //센서on/off
    "0005": null, //센서모드
    "0006": null, //배터리
    "0007": null, //모션에러
  };

  RxList<int> sensorModePuck2 = <int>[].obs;

  List<String> state = [];
  List<int> frequency = [];
  List<int> frequencyLevel = [];
  int sensorValue = 0;
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

      device.state.listen((state) async {
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
            // Todo ::: 스캔 리스트에서 연결중인 퍽 삭제
            var service = await setService(device);
            setCharacterList(device, service);
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

  Future<BluetoothService> setService(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    BluetoothService loopCoreService = services.firstWhere(
        (s) => s.uuid.toString().toUpperCase().substring(4, 8) == '4A56');
    print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
    print(loopCoreService);

    if (device.name == PUCK1)
      servicePuck1 = loopCoreService;
    else if (device.name == PUCK2) servicePuck2 = loopCoreService;

    return loopCoreService;
  }

  setCharacterList(BluetoothDevice device, BluetoothService service) async {
    List<BluetoothCharacteristic> charList = service.characteristics;

    for (int i = 0; i < charList.length; i++) {
      String uuid = charList[i].uuid.toString().toUpperCase().substring(4, 8);
      BluetoothCharacteristic characteristic = charList[i];
      print('🐳🐳🐳🐳🐳🐳🐳🐳');
      print(characteristic);
      if (device.name == PUCK1) {
        charPuck1[uuid] = characteristic;
      } else if (device.name == PUCK2) {
        charUuidPuck2[uuid] = characteristic;
      }
    }
  }
}
