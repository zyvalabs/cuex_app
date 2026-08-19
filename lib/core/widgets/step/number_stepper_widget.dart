import 'package:flutter/material.dart';

/// Reusable numeric stepper — label on top, tappable/editable value in middle, +/- buttons on sides.
/// Use for "Best of Frames", "Race to Points", or any incrementable value.
class NumberStepperWidget extends StatefulWidget {
  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final int step;
  final ValueChanged<int> onChanged;

  final Color labelColor;
  final double labelFontSize;
  final Color buttonColor;
  final Color buttonIconColor;
  final Color valueColor;
  final double valueFontSize;

  const NumberStepperWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.step = 1,
    this.labelColor = Colors.black,
    this.labelFontSize = 14,
    this.buttonColor = Colors.black,
    this.buttonIconColor = Colors.white,
    this.valueColor = Colors.black,
    this.valueFontSize = 22,
  });

  @override
  State<NumberStepperWidget> createState() => _NumberStepperWidgetState();
}

class _NumberStepperWidgetState extends State<NumberStepperWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant NumberStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep field in sync if value changes externally (e.g. via +/- buttons)
    if (oldWidget.value != widget.value) {
      _textController.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _decrement() {
    final newValue = widget.value - widget.step;
    if (newValue >= widget.minValue) widget.onChanged(newValue);
  }

  void _increment() {
    final newValue = widget.value + widget.step;
    if (newValue <= widget.maxValue) widget.onChanged(newValue);
  }

  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed != null && parsed >= widget.minValue && parsed <= widget.maxValue) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.labelColor,
            fontSize: widget.labelFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StepperButton(
              icon: Icons.remove,
              color: widget.buttonColor,
              iconColor: widget.buttonIconColor,
              onTap: _decrement,
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(
                  color: widget.valueColor,
                  fontSize: widget.valueFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add,
              color: widget.buttonColor,
              iconColor: widget.buttonIconColor,
              onTap: _increment,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}