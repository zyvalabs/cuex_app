import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  static const platform = MethodChannel('com.cuex.app/camera_preview');

  // Zoom state
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  // Focus indicator state
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  /// Handle tap to focus
  void _handleTapToFocus(TapUpDetails details) {
    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });

    // Send tap coordinates to native camera
    final RenderBox box = context.findRenderObject() as RenderBox;
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;

    platform.invokeMethod('tapToFocus', {
      'x': x,
      'y': y,
      'width': box.size.width,
      'height': box.size.height,
    }).then((focused) {
      print(focused ? '✅ Focus adjusted' : '⚠️ Focus failed');
    }).catchError((error) {
      print('❌ Tap to focus error: $error');
    });

    // Hide focus indicator after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFocusIndicator = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera preview with gestures
        GestureDetector(
          // Pinch to zoom
          onScaleStart: (details) {
            _baseZoom = _currentZoom;
          },
          onScaleUpdate: (details) {
            _currentZoom = (_baseZoom * details.scale).clamp(1.0, 5.0);
            platform.invokeMethod('setZoom', {'zoom': _currentZoom});
          },

          // Tap to focus
          onTapUp: _handleTapToFocus,

          child: const AndroidView(
            viewType: 'com.cuex.app/camera_preview',
            creationParamsCodec: StandardMessageCodec(),
          ),
        ),

        // Focus indicator (yellow square)
        if (_showFocusIndicator && _focusPoint != null)
          Positioned(
            left: _focusPoint!.dx - 40,
            top: _focusPoint!.dy - 40,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.2, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.yellow,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.yellow.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}