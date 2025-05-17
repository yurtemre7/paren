import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Calculator-style numeric keyboard widget.
class CalculatorKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const CalculatorKeyboard({
    super.key,
    required this.controller,
    this.onChanged,
  });

  void _append(String value) {
    var text = controller.text;
    if (value == ',' && text.contains(',')) return;
    if (value == ',' && text.isEmpty) {
      controller.text = '0,';
    } else {
      controller.text += value;
    }
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    onChanged?.call();
  }

  void _delete() {
    var text = controller.text;
    if (text.isNotEmpty) {
      controller.text = text.substring(0, text.length - 1);
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    }
    onChanged?.call();
  }

  void _clear() {
    controller.clear();
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width * 0.5,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (var i = 1; i <= 9; i++)
            _CalcButton(
              label: '$i',
              onTap: () => _append('$i'),
            ),
          _CalcButton(
            label: ',',
            onTap: () => _append(','),
          ),
          _CalcButton(
            label: '0',
            onTap: () => _append('0'),
          ),
          _CalcButton(
            label: 'C',
            onTap: _delete,
            onLongPress: _clear,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;

  const _CalcButton({
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.color,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  void _onLongPress() {
    _controller.forward(from: 0.0);
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        // Shake amplitude in pixels
        const double shakeAmount = 1.0;
        // Sine wave for shake effect
        double offsetX = math.sin(_offsetAnimation.value * math.pi * 4) *
            (1 - _offsetAnimation.value) *
            shakeAmount;
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: child,
        );
      },
      child: Material(
        color: context.theme.colorScheme.primaryContainer.withValues(
          alpha: context.theme.brightness == Brightness.light ? 1 : 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _onTap,
          onLongPress: _onLongPress,
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 18,
                color: widget.color ?? context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
