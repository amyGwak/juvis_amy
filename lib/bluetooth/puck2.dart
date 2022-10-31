import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Puck2 {

  List<BluetoothDevice> scanList = [];
  BluetoothDevice? selectedDevice;
  List<BluetoothService> services = [];
  BluetoothService? selectedService;
  List<BluetoothCharacteristic> charList = [];

  String connectState = "연결되지 않았습니다";
  bool connected = false;

  BluetoothCharacteristic? charState; //0001 특성
  BluetoothCharacteristic? charFreq; //0002 주파모드
  BluetoothCharacteristic? charFreqLevel; //0003 주파강도
  BluetoothCharacteristic? blueSensorOn; //0004 센서on/off
  BluetoothCharacteristic? blueSensorMode; //0005 센서모드
  BluetoothCharacteristic? blueBattery; //0006 배터리
  BluetoothCharacteristic? blueMotionErr; //0007 모션에러


  List<String> state = [];
  List<int> frequency = [];
  List<int> frequencyLevel = [];
  int sensorValue = 0;
  List<int> sensorMode = [];
  bool isSensorOn = false;
  bool isFrequencyOn = false;

  String battery = "0%";
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  static final Puck2 _cache = Puck2._internal();


  //초기화 코드
  Puck2._internal();

  // 팩토리 생성자 -> 싱글톤을 만들었다... 인스턴스 공유하기가 힘들다.
  // 찍어내는 것마다 같은 인스턴스이게 하고 싶다. 하나만 만들어줘

  factory Puck2() {
    return _cache;
  }

  Future<List<BluetoothDevice>> scan () async {
    print("✅✅scan Start!!!✅✅");
    await flutterBlue.startScan(timeout: Duration(seconds: 2));


    flutterBlue.scanResults.listen((results) {
      print("✅scan listen 시작✅");
      for(ScanResult r in results) {
        if(r.device.name == 'J-2') {
          print("✅J-2발견✅");
          if(scanList.every((device) => device.id != r.device.id)) {
            scanList.add(r.device);
          }
        }
      }
    });
    await flutterBlue.stopScan();
    print("🌼🌼${scanList}🌼🌼🌼🌼");
    return scanList;

  }

  switchConnect () async {
    // const scan
    if (!connected) {
      //연결이 안되어있으면 scan을 한다.

      print("✅✅스캔 시작✅✅");
      scanList = await scan();

      print("✅✅ ${scanList} scanList2 뱉어내기 ✅✅");

      for (var i = 0; i < scanList.length; i++) {
        await scanList[i].connect();
        selectedDevice = scanList[i];

        scanList[i].state.listen((state) {
          print("🐣🐣🐣🐣🐣state ${state}");

          switch (state) {
            case BluetoothDeviceState.connecting:
              connectState = "연결중입니다.";
              connected = true;
              break;
            case BluetoothDeviceState.disconnected:
              connectState = "연결되지 않았습니다";
              connected = false;
              break;
            case BluetoothDeviceState.connected:
              connectState = "연결되었습니다.";
              connected = true;
              break;
            default:
              connectState = "연결해제";
              connected = false;
          }
        });
      }
      print("🦋🦋connectState🦋🦋🦋 ${connectState}");
      //연결이 되면 service를 받아온다.
      await getServices();

      // 해당 서비스의 캐릭터리스트를 담는다.
      await setCharacterList();

    } else {
      // 연결이 되어있으면 연결을 끊어준다.
      await scanList[0].disconnect();
      print("🦋🦋🦋connectState🦋🦋🦋 ${connectState}");
    }
  }


  //함수
  void getDeviceConnect (BluetoothDevice device) async {
    print("✈️✈️device ${device}");
    selectedDevice = device;
    selectedDevice!.connect();
    if(selectedDevice!.state == BluetoothDeviceState.connected){
      connectState = "연결되었습니다";
    }


    print("✈️selectedDevice ${selectedDevice}");

  }


  getServices () async {
    print("🌼🌼🌼selectedDevice ${selectedDevice}");
    if (selectedDevice != null) {
      services = await selectedDevice!.discoverServices();
      selectedService = services.firstWhere((s) => s.uuid.toString().toUpperCase().substring(4, 8) == '4A56');

      print("🎀🎀${services} services");
      print("🐣🌼${selectedService} selectedService");
    }
  }

  setCharacterList() async {
    print("✅✅character 리스트 채울게요!");
    if(selectedService != null){
      charList = selectedService!.characteristics;
    }

    print("✅✅charList ${charList}");

    for(int i=0; i < charList.length; i++){
      //캐릭터 돌면서 캐릭터에 관련된 character를 담는다.
      getCharacter(charList[i]);
    }

  }

  //value를 listen 해준다.
  void listen() {
    charList.map((c) => c.value.listen((value) {
      getCharacterValue(c.uuid.toString().toUpperCase().substring(4,8), value);
    }));
  }

  getCharacterName (String uuid) {
    switch (uuid) {
      case '0001':
        return '특성';
      case '0002':
        return '주파모드';
      case '0003':
        return '주파강도';
      case '0004':
        return '센서on/off';
      case '0005':
        return '센서모드';
      case '0006':
        return '배터리';
      case '0007':
        return '모션에러';
      default:
        return '없음';
    }
  }

  //각각의 특성을 저장해둔다!
  getCharacter (BluetoothCharacteristic characteristic) {
    print("🥰🥰🥰🥰🥰🥰🥰characteristic ${characteristic}");
    String uuid = characteristic.uuid.toString().toUpperCase().substring(4,8);
    switch (uuid) {
      case '0001':
        charState = characteristic;
        break;
      case '0002':
        charFreq = characteristic;
        break;
      case '0003':
        charFreqLevel = characteristic;
        break;
      case '0004':
        blueSensorOn = characteristic;
        break;
      case '0005':
        blueSensorMode = characteristic;
        break;
      case '0006':
        blueBattery = characteristic;
        break;
      case '0007':
        blueMotionErr = characteristic;
        break;
    }
  }

  getCharacterValue (String uuid, List<int> value) {
    switch (uuid) {
      case '0001':
        state = getStateText(value);
        return state;
      case '0002':
        frequency = value;
        return frequency;
      case '0003':
        frequencyLevel = value;
        return frequencyLevel;
      case '0004':
        var type = "sensor";
        sensorValue = setSensorMode(value, type);
        return sensorValue;
      case '0005':
        sensorMode = value;
        return sensorMode;
      case '0006':
      //배터리
        battery = toHex(value);
        return battery;
      case '0007':
        return 1;
    }
  }

  String toHex (List<int>value) {
    var intValue = value.length == 0 ? 0 : value[0];
    if(value == 0) {
      return "0%";
    } else {
      var battery = int.parse(intValue.toRadixString(16)[0]) * 10;
      return "${battery}%";
    }
  }

  setSensorOn () async {
    print("🐳🐳🐳🐳🐳🐳🐳blueSensorOn ${blueSensorOn}");
    if(blueSensorOn != null){
      await blueSensorOn!.write([17], withoutResponse: false);
      var value = await blueSensorOn!.read();
      print("🦧🦧🦧🦧🦧🦧value!!!!! ${value}");
    }

  }

  setSensorOff () async {
    if(blueSensorOn != null) {
      await blueSensorOn!.write([0], withoutResponse: false);
      var value = await blueSensorOn!.read();
      print("🦧🦧🦧🦧🦧🦧value!!!!! ${value}");
    }

  }

  read (int idx) async {
    List<int> value = await charList[idx].read();
    return value;
  }


  getValue (int idx) async {
    List<int> value = await charList[idx].read();
    print("value $value");
    return value.isEmpty ? "[]" : value.toString;
  }

  void onSensor () {
    isSensorOn = !isSensorOn;
  }

  void onFrequency () {
    isFrequencyOn = !isFrequencyOn;
  }

  List<int> notifySensorValue () {
    return [1,2];
  }

  void readBattery () {

  }

  void readMotionError () {

  }

  void writeMotionError () {

  }

  String toText (int num) {
    switch (num) {
      case 0:
        return "factory";
      case 1:
        return "advertising";
      case 2:
        return "연결되었습니다.";
      case 3:
        return "주파모드를 켰습니다.";
      case 4:
        return "센서를 켰습니다.";
      case 5:
        return "퍽을 착용했습니다.";
      case 6:
        return "충전중입니다.";
      case 7:
        return "reserved";
      default:
        return "!!!";
    }
  }

  List<String> getStateText (List<int>value) {
    int intValue = value.length == 0 ? 0 : value[0];
    List<String> textList = [];
    String binary = intValue.toRadixString(2).padLeft(8, "0");

    for(int i=0; i < binary.length; i++){
      if(binary[i] == "1") {
        var index = binary.length - i - 1;
        textList.add(toText(index));
      }
    }
    return textList;
  }


  int setSensorMode (List<int>value, String type) {
    var intValue = value.length == 0 ? 100 : value[0];
    switch(intValue) {
      case 17:
        return type == "frequency" ? 1 : 16;
      case 16:
        return type == "frequency" ? 0 : 17;
      case 1:
        return type == "frequency" ? 17 : 0;
      case 0:
      case 100:
        return type == "frequency" ? 16 : 1;
      default:
        return type == "frequency" ? 0 : 0;
    }
  }


}