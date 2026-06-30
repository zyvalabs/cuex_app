// import 'package:battery_plus/battery_plus.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'dart:io';
// import 'dart:async';
//
// class DeviceService {
//   final _db = FirebaseDatabase.instanceFor(
//     app: Firebase.app(),
//     databaseURL: 'https://cuex-ab44c-default-rtdb.asia-southeast1.firebasedatabase.app/',
//   );
//   final _battery = Battery();
//   Timer? _heartbeatTimer;
//
//   Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     String id;
//     if (Platform.isAndroid) {
//       final d = await info.androidInfo;
//       id = d.id;
//     } else {
//       final d = await info.iosInfo;
//       id = d.identifierForVendor ?? 'unknown';
//     }
//     return id.replaceAll(RegExp(r'[.#$\[\]]'), '_');
//   }
//   Future<String> getDeviceName() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       final d = await info.androidInfo;
//       return '${d.brand} ${d.model}';
//     }
//     final d = await info.iosInfo;
//     return d.name;
//   }
//
//   Future<String?> getIPAddress() async {
//     try {
//       final interfaces = await NetworkInterface.list();
//       for (var i in interfaces) {
//         for (var addr in i.addresses) {
//           if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
//             return addr.address;
//           }
//         }
//       }
//     } catch (_) {}
//     return null;
//   }
//
//   Future<void> registerDevice() async {
//     print('Starting registration...');
//     final id = await getDeviceId();
//     print('Device ID: $id');
//     final name = await getDeviceName();
//     print('Device Name: $name');
//     final connectivity = await Connectivity().checkConnectivity();
//     final batteryLevel = await _battery.batteryLevel;
//     final ip = await getIPAddress();
//     print('IP: $ip, Battery: $batteryLevel, Wifi: $connectivity');
//
//     await _db.ref('devices/$id').set({
//       'id': id,
//       'name': name,
//       'ip': ip ?? 'unknown',
//       'battery': batteryLevel,
//       'wifi': connectivity.contains(ConnectivityResult.wifi),
//       'status': 'online',
//       'command': 'idle',
//       'lastSeen': ServerValue.timestamp,
//     });
//
//     print('Device registered successfully');
//     _startHeartbeat(id);
//   }
//
//   void _startHeartbeat(String deviceId) {
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
//       final batteryLevel = await _battery.batteryLevel;
//       final connectivity = await Connectivity().checkConnectivity();
//       final ip = await getIPAddress();
//       await _db.ref('devices/$deviceId').update({
//         'battery': batteryLevel,
//         'wifi': connectivity.contains(ConnectivityResult.wifi),
//         'ip': ip ?? 'unknown',
//         'status': 'online',
//         'lastSeen': ServerValue.timestamp,
//       });
//     });
//   }
//
//   void listenForCommands(String deviceId, Function(Map<dynamic, dynamic>) onCommand) {
//     _db.ref('devices/$deviceId/command').onValue.listen((event) {
//       final cmd = event.snapshot.value;
//       if (cmd is Map) onCommand(cmd);
//     });
//   }
//
//   Future<void> updateStatus(String deviceId, String status) async {
//     await _db.ref('devices/$deviceId').update({
//       'status': status,
//       'lastSeen': ServerValue.timestamp,
//     });
//   }
//
//   Future<void> setOffline(String deviceId) async {
//     await _db.ref('devices/$deviceId').update({
//       'status': 'offline',
//       'lastSeen': ServerValue.timestamp,
//     });
//   }
//
//   void dispose() {
//     _heartbeatTimer?.cancel();
//   }
// }