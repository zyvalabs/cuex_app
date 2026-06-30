// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:get/get.dart';
// import '../../../features/shop/screens/live streaming pedro/presentation/controllers/remote_streaming.dart';
// import 'device_service.dart';
//
// class DeviceController extends GetxController {
//   final _service = DeviceService();
//   final status = 'idle'.obs;
//   final battery = 0.obs;
//   final wifi = false.obs;
//   final ip = ''.obs;
//   late String deviceId;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _init();
//   }
//
//   void _init() async {
//     await _service.registerDevice();
//     deviceId = await _service.getDeviceId();
//     _service.listenForCommands(deviceId, (cmd) {
//       final action = cmd['action'] as String? ?? 'idle';
//       status.value = action;
//       if (action == 'start') _startMatch(cmd);
//       if (action == 'stop') _stopMatch();
//       if (action == 'updateScoreboard') _updateScoreboard(cmd);
//     });
//   }
//
//   void _startMatch(Map<dynamic, dynamic> command) async {
//     final matchId = command['matchId'] as String?;
//     if (matchId == null || matchId.isEmpty) return;
//
//     final coordinator = Get.isRegistered<RemoteStreamCoordinator>()
//         ? Get.find<RemoteStreamCoordinator>()
//         : Get.put(RemoteStreamCoordinator());
//
//     coordinator.setMatchId(matchId);
//     await coordinator.startPreview();
//     await coordinator.goLive(matchName: matchId);
//     await coordinator.updateScoreboard();
//
//     await _service.updateStatus(deviceId, 'streaming');
//     await FirebaseDatabase.instanceFor(
//       app: Firebase.app(),
//       databaseURL: 'https://cuex-ab44c-default-rtdb.asia-southeast1.firebasedatabase.app/',
//     ).ref('devices/$deviceId').update({'streamingMatchId': matchId});
//   }
//
//   void _stopMatch() async {
//     if (Get.isRegistered<RemoteStreamCoordinator>()) {
//       await Get.find<RemoteStreamCoordinator>().stopStream();
//     }
//     await _service.updateStatus(deviceId, 'online');
//     await FirebaseDatabase.instanceFor(
//       app: Firebase.app(),
//       databaseURL: 'https://cuex-ab44c-default-rtdb.asia-southeast1.firebasedatabase.app/',
//     ).ref('devices/$deviceId').update({'streamingMatchId': null});
//   }
//
//   void _updateScoreboard(Map<dynamic, dynamic> command) async {
//     final matchId = command['matchId'] as String?;
//     if (matchId == null || matchId.isEmpty) return;
//     final coordinator = Get.find<RemoteStreamCoordinator>();
//     coordinator.setMatchId(matchId);
//     await coordinator.updateScoreboard();
//   }
//
//   @override
//   void onClose() {
//     _service.setOffline(deviceId);
//     _service.dispose();
//     super.onClose();
//   }
// }