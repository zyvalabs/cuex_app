import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class TCarouselWidget extends StatefulWidget {
  const TCarouselWidget({
    super.key,
    required this.items,
    this.height = 200,
    this.autoPlay = true,
    this.showIndicators = true,
  });

  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final bool showIndicators;

  @override
  State<TCarouselWidget> createState() => _TCarouselWidgetState();
}

class _TCarouselWidgetState extends State<TCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            autoPlay: widget.autoPlay,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            onPageChanged: (index, _) {
              setState(() => _currentIndex = index);
            },
          ),
          items: widget.items,
        ),

        if (widget.showIndicators) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.items
                .asMap()
                .entries
                .map((entry) {
              return Container(
                width: _currentIndex == entry.key ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentIndex == entry.key
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}