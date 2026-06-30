

// ─────────────────────────────────────────────
// Horizontal Shimmer — for sliders while loading
// ─────────────────────────────────────────────

import 'package:cuex_app/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HorizontalShimmer extends StatelessWidget {
  const HorizontalShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(right: 12),
          width: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TShimmerEffect(width: 50, height: 18, radius: 8),
                  TShimmerEffect(width: 60, height: 12, radius: 4),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TShimmerEffect(width: 32, height: 32, radius: 16),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TShimmerEffect(width: 80, height: 12, radius: 4),
                      const SizedBox(height: 5),
                      TShimmerEffect(width: 50, height: 10, radius: 4),
                    ],
                  ),
                  const Spacer(),
                  TShimmerEffect(width: 32, height: 32, radius: 16),
                ],
              ),
              const SizedBox(height: 14),
              TShimmerEffect(width: 100, height: 10, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}