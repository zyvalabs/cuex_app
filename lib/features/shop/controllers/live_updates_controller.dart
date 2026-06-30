import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LiveUpdatesController extends GetxController {
  static LiveUpdatesController get instance => Get.find();

  RxList<LiveUpdateModel> updates = <LiveUpdateModel>[].obs;

  /// Add frame winner update
  void addFrameWinner(String playerName, String playerImage, String frameNumber, String score) {
    updates.insert(0, LiveUpdateModel(
      title: 'FRAME WON',
      playerName: playerName,
      playerImage: playerImage,
      subtitle: 'End of Frame $frameNumber',
      value: score,
      valueColor: Colors.greenAccent,
    ));
  }

  /// Add high break update
  void addHighBreak(String playerName, String playerImage, String frameNumber, int breakScore) {
    updates.insert(0, LiveUpdateModel(
      title: 'HIGH BREAK',
      playerName: playerName,
      playerImage: playerImage,
      subtitle: 'Frame $frameNumber',
      value: breakScore.toString(),
      valueColor: breakScore >= 100 ? Colors.purple : Colors.orange,
      showConfetti: breakScore >= 100,
    ));
  }

  /// Add match winner update
  void addMatchWinner(String playerName, String playerImage, String finalScore) {
    updates.insert(0, LiveUpdateModel(
      title: 'MATCH WINNER',
      playerName: playerName,
      playerImage: playerImage,
      subtitle: 'Wins the match',
      value: finalScore,
      valueColor: Colors.amber,
      showConfetti: true,
    ));
  }
}

class LiveUpdateModel {
  final String title;
  final String playerName;
  final String playerImage;
  final String? subtitle;
  final String? value;
  final Color valueColor;
  final bool showConfetti;

  LiveUpdateModel({
    required this.title,
    required this.playerName,
    required this.playerImage,
    this.subtitle,
    this.value,
    this.valueColor = Colors.greenAccent,
    this.showConfetti = false,
  });
}