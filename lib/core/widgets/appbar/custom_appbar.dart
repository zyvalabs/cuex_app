// import 'package:flutter/material.dart';
//
// /// Reusable top app bar — pass a title widget/logo, and optional trailing actions.
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final Widget title;
//   final List<Widget>? actions;
//   final Color backgroundColor;
//   final double height;
//
//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.actions,
//     this.backgroundColor = const Color(0xFFFFC72C), // brand yellow, change as needed
//     this.height = 64,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       color: backgroundColor,
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           title,
//           if (actions != null)
//             Row(mainAxisSize: MainAxisSize.min, children: actions!),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(height);
// }