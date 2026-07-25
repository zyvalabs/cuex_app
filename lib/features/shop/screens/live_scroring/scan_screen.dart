// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// import '../../../../data/repositories/matches/matches_repository.dart';
// import '../../../../utils/constants/colors.dart';
// import 'live_scoring.dart';
//
// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});
//
//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }
//
// class _ScanScreenState extends State<ScanScreen> {
//   final MobileScannerController cameraController = MobileScannerController();
//
//   bool isScanned = false;
//   bool hasPermission = false;
//   String? scannedMatchId;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkCameraPermission();
//   }
//
//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
//
//   /// -------------------------------
//   /// Camera Permission
//   /// -------------------------------
//   Future<void> _checkCameraPermission() async {
//     final status = await Permission.camera.status;
//
//     if (status.isGranted) {
//       setState(() => hasPermission = true);
//     } else {
//       final result = await Permission.camera.request();
//
//       if (result.isGranted) {
//         setState(() => hasPermission = true);
//       } else {
//         setState(() => hasPermission = false);
//       }
//     }
//   }
//
//   /// -------------------------------
//   /// QR Detect
//   /// -------------------------------
//   void _onDetect(BarcodeCapture capture) {
//     if (isScanned) return;
//
//     final barcodes = capture.barcodes;
//     for (final barcode in barcodes) {
//       if (barcode.rawValue != null) {
//         isScanned = true;
//         scannedMatchId = barcode.rawValue;
//         cameraController.stop();
//         _showMatchActions();
//         break;
//       }
//     }
//   }
//
//   /// -------------------------------
//   /// Bottom Sheet
//   /// -------------------------------
//   void _showMatchActions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey.shade900,
//       isDismissible: false,
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Match Found',
//               style: Theme.of(context)
//                   .textTheme
//                   .headlineSmall
//                   ?.copyWith(color: Colors.white),
//             ),
//             const SizedBox(height: 16),
//
//             Text(
//               'Match ID: $scannedMatchId',
//               style: const TextStyle(color: Colors.white70),
//             ),
//
//             const SizedBox(height: 24),
//
//             ElevatedButton(
//               onPressed: () async {
//                 Get.back();
//
//                 final match = await MatchRepository.instance
//                     .fetchSingleItem(scannedMatchId!);
//
//                 Get.to(() => LiveScoringScreen(match: match));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Start Scoring'),
//             ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: () {
//                 Get.back();
//                 isScanned = false;
//                 cameraController.start();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Cancel'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// -------------------------------
//   /// UI
//   /// -------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: TColors.peppercorn,
//       ),
//       body: hasPermission
//           ? Stack(
//         children: [
//           MobileScanner(
//             controller: cameraController,
//             onDetect: _onDetect,
//           ),
//         ],
//       )
//           : Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Iconsax.camera, size: 60),
//             const SizedBox(height: 16),
//             const Text('Camera permission required'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _checkCameraPermission,
//               child: const Text('Grant Permission'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
