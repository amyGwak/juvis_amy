import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const ROOPCORE1 = 'J-1';
const ROOPCORE2 = 'J-2';

class Bluetooth {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  Future<List<ScanResult>> scan() async {
    List<ScanResult> scanList = [];

    await flutterBlue.startScan(timeout: Duration(seconds: 2));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == ROOPCORE1 || r.device.name == ROOPCORE2) {
          if (scanList
              .every((scanResult) => scanResult.device.id != r.device.id)) {
            scanList = [...scanList, r];
          }
        }
      }
    });
    await flutterBlue.stopScan();
    return scanList;
  }

  Future<Stream<BluetoothDeviceState>>? connect(BluetoothDevice device) async {
    BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
    await device.connect();

    return device.state;
  }
}
