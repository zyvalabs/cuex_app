import 'package:get/get.dart';

/// Holds RTMP-specific setup — server URL and stream key.
class RtmpSetupController extends GetxController {
  final RxnString rtmpUrl = RxnString();
  final RxnString streamKey = RxnString();

  void setRtmpUrl(String value) => rtmpUrl.value = value;
  void setStreamKey(String value) => streamKey.value = value;

  bool get isRtmpSetupValid =>
      (rtmpUrl.value?.trim().isNotEmpty ?? false) && (streamKey.value?.trim().isNotEmpty ?? false);
}