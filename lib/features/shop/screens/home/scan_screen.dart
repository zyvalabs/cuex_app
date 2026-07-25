// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// import '../../../../utils/constants/colors.dart';
// import '../../../../utils/popups/loaders.dart';
// import '../../../personalization/controllers/user_controller.dart';
// import '../../models/match_model.dart';
// import '../../screens/live streaming pedro/presentation/screens/LiveStreamingScreen.dart';
// import '../../screens/live_scroring/live_scoring.dart';
// import '../../screens/matches/match_detail.dart';
// import '../../screens/players/player_stat_screen.dart';
// import '../../screens/venues/venue_screen.dart';
// import '../../../shop/controllers/matches_controller.dart';
//
// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});
//
//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }
//
// class _ScanScreenState extends State<ScanScreen> {
//   final MobileScannerController _scanController = MobileScannerController();
//   bool _isProcessing = false;
//
//   @override
//   void dispose() {
//     _scanController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _onDetect(BarcodeCapture capture) async {
//     if (_isProcessing) return;
//     final barcode = capture.barcodes.firstOrNull;
//     if (barcode?.rawValue == null) return;
//
//     setState(() => _isProcessing = true);
//     await _scanController.stop();
//
//     final value = barcode!.rawValue!;
//     await _handleScan(value);
//
//     await Future.delayed(const Duration(seconds: 2));
//     if (mounted) {
//       setState(() => _isProcessing = false);
//       await _scanController.start();
//     }
//   }
//
//   Future<void> _handleScan(String value) async {
//     // ── Try match QR ──────────────────────
//     try {
//       final match = await MatchController.instance.getMatch(value);
//       if (match != null) {
//         final currentUser = UserController.instance.user.value;
//         final isCreator = currentUser.id == match.createdBy ||
//             currentUser.id == match.player1Id;
//
//         if (isCreator) {
//           // Show options — stream or score
//           _showMatchOptions(match);
//         } else {
//           // Just view match detail
//           Get.to(() => MatchDetailScreen(match: match));
//         }
//         return;
//       }
//     } catch (_) {}
//
//     // ── Try player QR ─────────────────────
//     try {
//       final user = await UserController.instance.getUserById(value);
//       if (user.id.isNotEmpty) {
//         Get.to(() => PlayerStatsScreen(targetUser: user));
//         return;
//       }
//     } catch (_) {}
//
//     // ── Unknown QR ────────────────────────
//     TLoaders.warningSnackBar(
//       title: 'Unknown QR',
//       message: 'This QR code is not recognized by CueX.',
//     );
//   }
//
//   void _showMatchOptions(MatchModel match) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF161616),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 36,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Match QR scanned',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'What would you like to do?',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.4),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _OptionTile(
//                 icon: Iconsax.video,
//                 label: 'Start Streaming',
//                 color: Colors.red,
//                 onTap: () {
//                   Navigator.pop(context);
//                   Get.to(() => LiveStreamingScreen(match: match));
//                 },
//               ),
//               const SizedBox(height: 8),
//               _OptionTile(
//                 icon: Iconsax.edit,
//                 label: 'Start Scoring',
//                 color: TColors.june,
//                 onTap: () {
//                   Navigator.pop(context);
//                   Get.to(() => LiveScoringScreen(match: match));
//                 },
//               ),
//               const SizedBox(height: 8),
//               _OptionTile(
//                 icon: Iconsax.eye,
//                 label: 'View Match',
//                 color: Colors.white54,
//                 onTap: () {
//                   Navigator.pop(context);
//                   Get.to(() => MatchDetailScreen(match: match));
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── Header ───────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//               child: Row(
//                 children: [
//                   // GestureDetector(
//                   //   onTap: () => Get.back(),
//                   //   child: Container(
//                   //     width: 36,
//                   //     height: 36,
//                   //     decoration: BoxDecoration(
//                   //       color: Colors.white.withOpacity(0.06),
//                   //       shape: BoxShape.circle,
//                   //     ),
//                   //     child: const Icon(
//                   //       Icons.close_rounded,
//                   //       size: 18,
//                   //       color: Colors.white70,
//                   //     ),
//                   //   ),
//                   // ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Scan',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Camera viewfinder ─────────────
//             Expanded(
//               flex: 5,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   MobileScanner(
//                     controller: _scanController,
//                     onDetect: _onDetect,
//                   ),
//
//                   // Dark overlay
//                   Container(color: Colors.black.withOpacity(0.3)),
//
//                   // Corner guides
//                   const _ScanFrame(),
//
//                   // Scan line
//                   Container(
//                     width: 180,
//                     height: 1.5,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.transparent,
//                           TColors.june,
//                           Colors.transparent,
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Processing indicator
//                   if (_isProcessing)
//                     Container(
//                       color: Colors.black54,
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: TColors.june,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                     ),
//
//                   // Hint text
//                   Positioned(
//                     bottom: 16,
//                     child: Text(
//                       'Point camera at any CueX QR code',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.white.withOpacity(0.4),
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── What you can scan ─────────────
//             Expanded(
//               flex: 3,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                 color: const Color(0xFF0D0D0D),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'WHAT YOU CAN SCAN',
//                       style: TextStyle(
//                         fontSize: 9,
//                         color: Colors.white,
//                         letterSpacing: 2,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     _BulletPoint(
//                       icon: Iconsax.video,
//                       text: 'Match QR — go live or start scoring',
//                       color: TColors.june,
//                     ),
//                     _BulletPoint(
//                       icon: Iconsax.user,
//                       text: 'Player QR — view their profile and stats',
//                     ),
//                     _BulletPoint(
//                       icon: Iconsax.building,
//                       text: 'Venue QR — explore venue and events',
//                     ),
//                     _BulletPoint(
//                       icon: Iconsax.scan_barcode,
//                       text: 'Add opponent for a practice match',
//                       isLast: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Scan Frame — corner guides
// // ─────────────────────────────────────────────
//
// class _ScanFrame extends StatelessWidget {
//   const _ScanFrame();
//
//   @override
//   Widget build(BuildContext context) {
//     const size = 180.0;
//     const corner = 24.0;
//     const thickness = 2.5;
//     const color = TColors.june;
//
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         children: [
//           // Top left
//           Positioned(
//             top: 0, left: 0,
//             child: _Corner(w: corner, h: corner, t: thickness, top: true, left: true, color: color),
//           ),
//           // Top right
//           Positioned(
//             top: 0, right: 0,
//             child: _Corner(w: corner, h: corner, t: thickness, top: true, left: false, color: color),
//           ),
//           // Bottom left
//           Positioned(
//             bottom: 0, left: 0,
//             child: _Corner(w: corner, h: corner, t: thickness, top: false, left: true, color: color),
//           ),
//           // Bottom right
//           Positioned(
//             bottom: 0, right: 0,
//             child: _Corner(w: corner, h: corner, t: thickness, top: false, left: false, color: color),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Corner extends StatelessWidget {
//   const _Corner({
//     required this.w,
//     required this.h,
//     required this.t,
//     required this.top,
//     required this.left,
//     required this.color,
//   });
//
//   final double w, h, t;
//   final bool top, left;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: w,
//       height: h,
//       child: CustomPaint(
//         painter: _CornerPainter(
//           color: color,
//           thickness: t,
//           top: top,
//           left: left,
//         ),
//       ),
//     );
//   }
// }
//
// class _CornerPainter extends CustomPainter {
//   const _CornerPainter({
//     required this.color,
//     required this.thickness,
//     required this.top,
//     required this.left,
//   });
//
//   final Color color;
//   final double thickness;
//   final bool top, left;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = thickness
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final path = Path();
//     if (top && left) {
//       path.moveTo(0, size.height);
//       path.lineTo(0, 0);
//       path.lineTo(size.width, 0);
//     } else if (top && !left) {
//       path.moveTo(0, 0);
//       path.lineTo(size.width, 0);
//       path.lineTo(size.width, size.height);
//     } else if (!top && left) {
//       path.moveTo(0, 0);
//       path.lineTo(0, size.height);
//       path.lineTo(size.width, size.height);
//     } else {
//       path.moveTo(0, size.height);
//       path.lineTo(size.width, size.height);
//       path.lineTo(size.width, 0);
//     }
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(_) => false;
// }
//
// // ─────────────────────────────────────────────
// // Bullet Point
// // ─────────────────────────────────────────────
//
// class _BulletPoint extends StatelessWidget {
//   const _BulletPoint({
//     required this.icon,
//     required this.text,
//     this.color,
//     this.isLast = false,
//   });
//
//   final IconData icon;
//   final String text;
//   final Color? color;
//   final bool isLast;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 14,
//             color: color ?? Colors.white.withOpacity(0.6),
//           ),
//           const SizedBox(width: 10),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Option Tile (bottom sheet)
// // ─────────────────────────────────────────────
//
// class _OptionTile extends StatelessWidget {
//   const _OptionTile({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 18, color: color),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }