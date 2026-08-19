// import 'package:cuex_app/screens/stream/rtmp/rtmp_screen.dart';
// import 'package:cuex_app/screens/stream/youtube/youtube_setup_screen.dart';
// import 'package:flutter/material.dart';
//
// import '../../core/utils/constants/app_colors.dart';
// import '../../core/widgets/cards/platform_options_card.dart';
// import '../../core/widgets/step/step_widget.dart';
// import '../../core/widgets/title/section_title_widget.dart';
// import '../../widgets/common/custom_app_bar.dart';
//
//
// class StreamingPlatformScreen extends StatelessWidget {
//   const StreamingPlatformScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: CustomAppBar(
//         backgroundColor: AppColors.green,
//         title: 'New Match',
//         showBackButton: true,
//         rightActions: [
//           IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 16),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24),
//               child: StepWidget(totalSteps: 4, currentStep: 3),
//             ),
//             const SizedBox(height: 24),
//             const SectionTitleWidget(
//               title: 'Choose Streaming Platform',
//               textAlign: TextAlign.left,
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: PlatformOptionCard(
//                       icon: Icons.play_circle_fill,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const YoutubeSetupScreen()),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: PlatformOptionCard(
//                       icon: Icons.settings_input_antenna,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const RtmpSetupScreen()),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }