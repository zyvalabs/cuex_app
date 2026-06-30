import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CueXTabBar extends StatelessWidget {
  const CueXTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.toggle,
    this.liveTabIndex,
    this.liveCount,
  });

  final List<String> tabs;
  final TabController? controller;
  final Widget? toggle;
  final int? liveTabIndex;
  final RxList? liveCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (toggle != null) toggle!,
        Container(
          color: const Color(0xFF121212),
          child: TabBar(
            controller: controller,

            isScrollable: true,
            indicatorColor: Colors.red,

            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.white.withOpacity(0.08),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            tabs: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final label = entry.value;
              final isLiveTab = liveTabIndex == i;

              if (isLiveTab && liveCount != null) {
                return Obx(() {
                  final hasLive = liveCount!.isNotEmpty;
                  return Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasLive)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(label),
                      ],
                    ),
                  );
                });
              }
              return Tab(text: label);
            }).toList(),
          ),
        ),
      ],
    );
  }
}