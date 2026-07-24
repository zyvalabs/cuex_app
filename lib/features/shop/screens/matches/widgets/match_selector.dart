import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact stepper row for match length.
/// - Tap +/- to increment
/// - Tap the number to edit it inline
class MatchLengthStepper extends StatefulWidget {
  const MatchLengthStepper({
    super.key,
    required this.sportName,
    required this.value,
    required this.onChanged,
  });

  final String? sportName;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<MatchLengthStepper> createState() => _MatchLengthStepperState();
}

class _MatchLengthStepperState extends State<MatchLengthStepper> {
  static const Color _accent = Color(0xFF0F6E56);
  static const Color _border = Color(0xFFE5E5E5);

  late final TextEditingController _controller =
  TextEditingController(text: widget.value.toString());
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(covariant MatchLengthStepper old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _key => widget.sportName?.toLowerCase().trim() ?? '';

  bool get _isRace =>
      _key == 'pool' || _key == 'heyball' || _key == 'chinese 8-ball';

  bool get _isPoints => _key == 'billiards';

  String get _label {
    if (_isRace) return 'Race to';
    if (_isPoints) return 'Points target';
    return 'Best of';
  }

  String get _hint {
    if (_isRace) return 'Frames to win, e.g. 7';
    if (_isPoints) return 'Target score, e.g. 150';
    return 'Total frames, e.g. 5';
  }

  int get _step => _isPoints ? 25 : (_isRace ? 1 : 2);

  int get _min => _isPoints ? 25 : 1;

  int get _max => _isPoints ? 1000 : 35;

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    final clamped = (parsed ?? widget.value).clamp(_min, _max);
    _controller.text = clamped.toString();
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _bump(int delta) {
    final next = (widget.value + delta).clamp(_min, _max);
    _controller.text = next.toString();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sportName == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _hint,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundButton(
                icon: Icons.remove,
                filled: false,
                enabled: widget.value - _step >= _min,
                onTap: () => _bump(-_step),
              ),
              const SizedBox(width: 10),
              Container(
                width: 52,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onSubmitted: (_) => _commit(),
                  onTapOutside: (_) => _focusNode.unfocus(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _RoundButton(
                icon: Icons.add,
                filled: true,
                enabled: widget.value + _step <= _max,
                onTap: () => _bump(_step),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;

  static const Color _accent = Color(0xFF0F6E56);
  static const Color _border = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled
              ? (enabled ? _accent : _accent.withOpacity(0.3))
              : Colors.white,
          border: filled ? null : Border.all(color: _border),
        ),
        child: Icon(
          icon,
          size: 15,
          color: filled
              ? Colors.white
              : (enabled ? Colors.black54 : Colors.grey.shade300),
        ),
      ),
    );
  }
}