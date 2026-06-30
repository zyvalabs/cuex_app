
import 'package:cuex_app/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsShimmer extends StatelessWidget {
  const NewsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const TShimmerEffect(width: 85, height: 130, radius: 0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TShimmerEffect(width: 55, height: 16, radius: 99),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TShimmerEffect(width: double.infinity, height: 11, radius: 4),
                          const SizedBox(height: 5),
                          TShimmerEffect(width: 120, height: 11, radius: 4),
                        ],
                      ),
                      TShimmerEffect(width: 70, height: 10, radius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}