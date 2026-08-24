import 'package:flutter/material.dart';

/// Small "vs" label divider between Side A and Side B.
class VsDivider extends StatelessWidget {
  const VsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text('vs', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}