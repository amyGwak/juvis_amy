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

  RxList<List<int>> sensorModePuck1 = RxList<List<int>>([]);

//PUCK2

  //flutter_blue_plus용 퍽 연결상태 state
  Rx<BluetoothDeviceState> connectStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  //임의로 만든 퍽 연결상태 state
  Rx<BluetoothDeviceState> deviceStatePuck2 =
      Rx<BluetoothDeviceState>(BluetoothDeviceState.disconnected);
  Rx<BluetoothDevice?> puck2 = Rx<BluetoothDevice?>(null);
  BluetoothService? servicePuck2;
  Map<String, BluetoothCharacteristic?> charPuck2 = {
    "0001": null, //state
    "0002": null, //주파모드
    "0003": null, //주파강도
    "0004": null, //센서on/off
    "0005": null, //센서모드
    "0006": null, //배터리
    "0007": null, //모션에러
  };

  RxList<List<int>> sensorModePuck2 = RxList<List<int>>([]);

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
            await setCharacterList(device, service);
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
        charPuck2[uuid] = characteristic;
      }
      print(charPuck1[uuid]);
    }
  }

  setSensorOnOff(bool frequency, bool sensor, BluetoothDevice device) async {
    BluetoothCharacteristic? _char = _deviceToCharList(device)['0004'];

    print(_char);

    if (_char == null || _char.properties.write == false) return;

    print('🔥🔥🔥🔥');

    if (frequency == true && sensor == true) {
      await _char.write([17]);
    } else if (frequency == true && sensor == false) {
      await _char.write([16]);
    } else if (frequency == false && sensor == true) {
      await _char.write([1]);
    } else if (frequency == false && sensor == false) {
      await _char.write([0]);
    }
  }

  setFrequencyMode(int mode, int seconds, BluetoothDevice device) async {
    BluetoothCharacteristic? _char = _deviceToCharList(device)['0002'];
    if (_char == null || _char.properties.write == false) return;

    await _char.write([mode, seconds]);
    read('0002', device);
  }

  setFrequencyIntensity(int intensity, BluetoothDevice device) async {
    BluetoothCharacteristic? _char = _deviceToCharList(device)['0003'];
    if (_char == null || _char.properties.write == false) return;

    await _char.write([intensity]);
    read('0003', device);
  }

  read(String charKey, BluetoothDevice device) async {
    BluetoothCharacteristic? _char = _deviceToCharList(device)[charKey];

    if (_char == null || _char.properties.read == false) return;

    List<int> result = await _char.read();

    print(result);
    return result;
  }

  notify(String charKey, BluetoothDevice device, bool toogle) async {
    BluetoothCharacteristic? _char = _deviceToCharList(device)[charKey];

    if (_char == null || _char.properties.notify == false) return;

    await _char.setNotifyValue(toogle);

    if (toogle == true) {
      _char.value.listen((event) {
        if (charKey == '0005') {
          if (device.name == PUCK1) {
            sensorModePuck1.value.add(event);
            print(
                '${sensorModePuck1.value.length - 1} : ${sensorModePuck1.value[sensorModePuck1.length - 1]} : ${event}');

            print("sensorModePuck2, ${sensorModePuck2}");
          } else if (device.name == PUCK2) {
            sensorModePuck2.value.add(event);
          }
        }
      });
    }
  }

  Map<String, BluetoothCharacteristic?> _deviceToCharList(
      BluetoothDevice device) {
    if (device.name == PUCK1)
      return charPuck1;
    else
      return charPuck2;
  }
}
