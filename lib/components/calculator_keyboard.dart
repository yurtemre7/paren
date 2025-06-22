import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

/// Calculator-style numeric keyboard widget.
class CalculatorKeyboard extends StatefulWidget {
  final RxString input;

  const CalculatorKeyboard({
    super.key,
    required this.input,
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  final Paren paren = Get.find();

  void _append(String value) {
    var text = widget.input.value;

    // Limit total length to 25
    if (text.length >= 25) return;

    // Only allow one '.'
    if (value == '.' && text.contains('.')) return;

    // If '.' is first, prepend '0'
    if (value == '.' && text.isEmpty) {
      widget.input.value = '0.';
      return;
    }

    // If already has '.', allow only 2 digits after it
    if (text.contains('.')) {
      int dotIndex = text.indexOf('.');
      int decimals = text.length - dotIndex - 1;
      if (dotIndex != -1 && decimals >= 2 && value != '.') return;
    }

    // Remove leading zeros (but keep '0.' and '0')
    String newText = text + value;
    if (newText.startsWith('0') && !newText.startsWith('0.') && newText.length > 1) {
      newText = newText.replaceFirst(RegExp(r'^0+'), '');
    }

    widget.input.value = newText;

    // print('input: $text');
    // print('input.value: ${input.value}');
  }

  void _delete() {
    var text = widget.input.value;
    if (text.isNotEmpty) {
      if (text.length == 1) {
        widget.input.value = '0';
      } else {
        widget.input.value = text.substring(0, text.length - 1);
      }
    }
    // print('input: $text');
    // print('input.value: ${input.value}');
  }

  void _clear() {
    widget.input.value = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Container(
          constraints: BoxConstraints(
            maxWidth: paren.calculatorInputHeight.value,
            // maxWidth: context.width * 0.5,
          ),
          child: Column(
            children: [
              Text(
                widget.input.value,
                style: TextStyle(
                  fontSize: 28,
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: context.theme.colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              16.h,
              GridView.count(
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
                    label: '.',
                    onTap: () => _append('.'),
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
              8.h,
            ],
          ),
        );
      },
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
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onLongPress() {
    _controller.forward(from: 0.0);
    HapticFeedback.mediumImpact();
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
