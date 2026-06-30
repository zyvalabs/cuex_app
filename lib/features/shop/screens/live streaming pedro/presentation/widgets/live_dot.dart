import 'package:flutter/material.dart';

class LiveDot extends StatefulWidget {
  final double size;
  final Color color;
  final bool showLabel;

  const LiveDot({
    super.key,
    this.size = 10,
    this.color = Colors.red,
    this.showLabel = true,
  });

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(_animation.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_animation.value * 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 6),
          // Text(
          //   'LIVE',
          //   style: TextStyle(
          //     color: widget.color,
          //     fontSize: 12,
          //     fontWeight: FontWeight.bold,
          //     letterSpacing: 1.5,
          //   ),
          // ),
        ],
      ],
    );
  }
}