import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';

class CalculatorKeyboard extends StatefulWidget {
  final RxString input;

  const CalculatorKeyboard({super.key, required this.input});

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  final Paren paren = Get.find();
  final focusNode = FocusNode();

  void _append(String value) {
    var text = widget.input.value;
    if (text.length >= 25) return;
    if (value == '.' && text.contains('.')) return;

    if (value == '.' && text.isEmpty) {
      widget.input.value = '0.';
      return;
    }

    if (value == '0' && text == '0') {
      return;
    }

    if (text.contains('.')) {
      int dotIndex = text.indexOf('.');
      int decimals = text.length - dotIndex - 1;
      if (dotIndex != -1 && decimals >= 2 && value != '.') return;
    }

    String newText = text + value;
    if (newText.startsWith('0') &&
        !newText.startsWith('0.') &&
        newText.length > 1) {
      newText = newText.replaceFirst(RegExp(r'^0+'), '');
    }

    widget.input.value = newText;
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
  }

  void _clear() {
    widget.input.value = '0';
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      var keyLabel = event.logicalKey.keyLabel;

      if (RegExp(r'^\d$').hasMatch(keyLabel)) {
        _append(keyLabel);
      } else if (keyLabel == '.' || keyLabel == ',') {
        _append('.');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
          event.logicalKey == LogicalKeyboardKey.delete) {
        _delete();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _clear();
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: handleKeyEvent,
        child: GestureDetector(
          onTap: () => focusNode.requestFocus(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: paren.calculatorInputHeight.value,
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SelectableText(
                        widget.input.value,
                        style: TextStyle(
                          fontSize: 22,
                          color: context.theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    10.h,
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.2,
                      children: [
                        for (var i = 1; i <= 9; i++)
                          _CalcButton(label: '$i', onTap: () => _append('$i')),
                        _CalcButton(label: '.', onTap: () => _append('.')),
                        _CalcButton(label: '0', onTap: () => _append('0')),
                        _CalcButton(
                          label: '⌫',
                          onTap: _delete,
                          onLongPress: _clear,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
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
        const amplitude = 1.0;
        double dx = math.sin(_offsetAnimation.value * math.pi * 5) * amplitude;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Material(
        color:
            widget.color?.withValues(alpha: 0.16) ??
            context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _onTap,
          onLongPress: widget.onLongPress != null ? _onLongPress : null,
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: widget.color ?? context.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
