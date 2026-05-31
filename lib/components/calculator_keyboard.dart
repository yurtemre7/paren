import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
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
  final currentStrIdx = 3.obs;

  int newCursorPosition(String number) {
    var cursorIdx = 0;
    var len = number.length;
    if (number[len - 1] == '0') {
      cursorIdx = 1;
      if (number[len - 2] == '0') {
        cursorIdx = 3; // left of the separator (, or .)
      }
    }

    return cursorIdx;
  }

  void _append(String value) {
    var text = widget.input.value;
    if (text.length >= 25) return;
    if (value == '.' && text.contains('.')) return;

    if (!text.contains('.') && value == '.') {
      currentStrIdx.value = 1;
    }

    if (value == '.' && text.isEmpty) {
      widget.input.value = '0.';
      currentStrIdx.value = 1;
      return;
    }

    if (value == '0' && text == '0') {
      return;
    }

    if (text.contains('.')) {
      int dotIndex = text.indexOf('.');
      int decimals = text.length - dotIndex - 1;
      if (dotIndex != -1 && decimals >= 2 && value != '.') return;
      if (currentStrIdx.value != 0) {
        currentStrIdx.value -= 1;
      }
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
        currentStrIdx.value = 3;
      } else if (text.length >= 2 && text[text.length - 1] == '.') {
        widget.input.value = text.substring(0, text.length - 2);
        currentStrIdx.value = 3;
      } else {
        widget.input.value = text.substring(0, text.length - 1);
        if (text.contains('.')) {
          if (currentStrIdx.value != 1) {
            currentStrIdx.value = currentStrIdx.value + 1;
          } else {
            widget.input.value = widget.input.value.replaceAll('.', '');
            currentStrIdx.value = 3;
          }
        }
      }
    }
  }

  void _clear() {
    widget.input.value = '0';
    currentStrIdx.value = 3;
  }

  Future<void> handleKeyEvent(KeyEvent event) async {
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
      } else if (keyLabel.toLowerCase() == 'r') {
        paren.latestTimestamp.value = DateTime.now();
        paren.fetchCurrencyDataOnline();
      } else if (keyLabel.toLowerCase() == 'v') {
        var clipboardData = await Clipboard.getData('text/plain');
        var clipboardText = clipboardData?.text ?? '0.0';
        clipboardText = clipboardText.replaceAll(',', '.')..trim();
        var clipboardDouble = double.tryParse(clipboardText) ?? 0.0;
        clipboardText = clipboardDouble.toStringAsFixed(2);

        var cursorPosition = newCursorPosition(clipboardText);
        widget.input.value = clipboardText.substring(
          0,
          clipboardText.length - cursorPosition,
        );
        currentStrIdx.value = cursorPosition;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var input = (double.tryParse(widget.input.value) ?? 0.0).toStringAsFixed(2);
    currentStrIdx.value = newCursorPosition(input);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var inputStringFormatted = NumberFormat.simpleCurrency(
        locale: context.l10n.localeName,
        name: '',
        decimalDigits: 2,
      ).format(double.tryParse(widget.input.value) ?? 0.0).trim();

      var inputStringFormattedRev = inputStringFormatted.characters
          .toList()
          .reversed
          .join();

      return KeyboardListener(
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
                    AnimatedText(
                      inputStringFormattedRev: inputStringFormattedRev,
                      currentStrIdx: currentStrIdx.value,
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
                        _CalcButton(
                          label: context.localeDecimalSeparator,
                          onTap: () => _append('.'),
                        ),
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
      );
    });
  }
}

class AnimatedText extends StatefulWidget {
  const AnimatedText({
    super.key,
    required this.inputStringFormattedRev,
    required this.currentStrIdx,
  });

  final String inputStringFormattedRev;
  final int currentStrIdx;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _decorationColorAnimation;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      animationBehavior: .preserve,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _decorationColorAnimation = ColorTween(
      begin: context.theme.colorScheme.onSurfaceVariant,
      end: Colors.transparent,
    ).animate(_pulseController);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SelectionArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text.rich(
              TextSpan(
                children: [
                  ...widget.inputStringFormattedRev.characters.indexed
                      .map(
                        ((int, String) element) => TextSpan(
                          text: element.$2,
                          style: TextStyle(
                            fontSize: 22,
                            color: context.theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            decoration: element.$1 == widget.currentStrIdx
                                ? .underline
                                : .none,
                            decorationColor: element.$1 == widget.currentStrIdx
                                ? _decorationColorAnimation.value
                                : Colors.transparent,
                          ),
                        ),
                      )
                      .toList()
                      .reversed,
                ],
              ),
            ),
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

class _CalcButtonState extends State<_CalcButton> {
  void _onTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress != null ? _onLongPress : null,
      child: GlassIconButton(
        icon: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: widget.color ?? context.theme.colorScheme.onSurface,
            ),
          ),
        ),
        onPressed: _onTap,
        glowRadius: 0,
        settings: LiquidGlassSettings().copyWith(
          glassColor:
              widget.color?.withValues(alpha: 0.16) ??
              context.theme.colorScheme.surface,
        ),
        shape: GlassIconButtonShape.roundedSquare,
      ),
    );
  }
}
