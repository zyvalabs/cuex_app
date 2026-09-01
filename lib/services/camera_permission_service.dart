import 'package:permission_handler/permission_handler.dart';

/// Result of a permission check — tells the caller exactly what to do next.
enum PermissionResult {
  granted, // both camera and mic granted — proceed
  denied, // at least one was denied but can still ask again
  permanentlyDenied, // at least one was permanently denied — must open Settings
}

/// Checks and requests camera + microphone permissions together, since
/// live streaming needs both. Wraps permission_handler so the rest of the
/// app never talks to that package directly.
class CameraPermissionService {
  /// Checks current status without prompting — use this to silently know
  /// where things stand (e.g. for a settings screen toggle display).
  Future<bool> hasCameraAndMicPermission() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return camera.isGranted && mic.isGranted;
  }

  /// Requests both permissions (shows system dialogs if not yet decided).
  /// Returns a PermissionResult so the caller knows exactly how to react —
  /// granted (proceed), denied (can retry), or permanentlyDenied (must
  /// send the user to Settings since re-prompting won't work).
  Future<PermissionResult> requestCameraAndMicPermission() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraStatus = statuses[Permission.camera]!;
    final micStatus = statuses[Permission.microphone]!;

    if (cameraStatus.isGranted && micStatus.isGranted) {
      return PermissionResult.granted;
    }

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  /// Opens the device's app settings page — the only way to fix a
  /// permanently-denied permission, since re-requesting won't show
  /// the system dialog again once denied that way.
  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}