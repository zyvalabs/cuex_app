import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CueStickAnimation extends StatefulWidget {
  const CueStickAnimation({super.key});

  @override
  State<CueStickAnimation> createState() => _CueStickAnimationState();
}

class _CueStickAnimationState extends State<CueStickAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cue ball (center)
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),

            SizedBox(height: 16 + _animation.value),

            // Cue stick (two white lines)
            Column(
              children: [
                Container(
                  width: 3,
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 3,
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                // Big brown circle at bottom
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}