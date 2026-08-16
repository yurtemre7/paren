import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  final firstOperand = Rxn<double>();
  final pendingOperation = Rxn<String>();
  final expressionTokens = <String>[];
  final fullExpression = ''.obs;
  var resetOnNextDigit = false;
  var isEvaluated = false;

  String _formatNum(double val) {
    if (val % 1 == 0) {
      return val.toInt().toString();
    } else {
      var str = val.toStringAsFixed(2);
      if (str.endsWith('0')) {
        str = str.substring(0, str.length - 1);
      }
      return str;
    }
  }

  double _computeTokens(List<String> tokens) {
    if (tokens.isEmpty) return 0.0;
    var result = double.tryParse(tokens[0]) ?? 0.0;
    for (var i = 1; i < tokens.length; i += 2) {
      if (i + 1 >= tokens.length) break;
      var op = tokens[i];
      var nextNum = double.tryParse(tokens[i + 1]) ?? 0.0;
      switch (op) {
        case '+':
          result += nextNum;
        case '-':
        case '−':
          result -= nextNum;
        case '×':
        case '*':
          result *= nextNum;
        case '÷':
        case '/':
          result = nextNum != 0 ? result / nextNum : 0.0;
      }
      result = double.parse(result.toStringAsFixed(2));
    }
    return result;
  }

  int newCursorPosition(String number) {
    var cursorIdx = 0;
    var len = number.length;
    if (len > 0 && number[len - 1] == '0') {
      cursorIdx = 1;
      if (len > 1 && number[len - 2] == '0') {
        cursorIdx = 3; // left of the separator (, or .)
      }
    }

    return cursorIdx;
  }

  void _append(String value) {
    if (isEvaluated) {
      expressionTokens.clear();
      fullExpression.value = '';
      isEvaluated = false;
      resetOnNextDigit = false;
      if (value == '.') {
        widget.input.value = '0.';
        currentStrIdx.value = 1;
      } else {
        widget.input.value = value;
        currentStrIdx.value = 3;
      }
      return;
    }

    if (resetOnNextDigit) {
      resetOnNextDigit = false;
      if (value == '.') {
        widget.input.value = '0.';
        currentStrIdx.value = 1;
      } else {
        widget.input.value = value;
        currentStrIdx.value = 3;
      }
      widget.input.refresh();
      fullExpression.value =
          '${expressionTokens.join(' ')} ${widget.input.value}';
      return;
    }

    var text = widget.input.value;
    if (text.length >= 25) return;
    if (value == '.' && text.contains('.')) return;

    if (!text.contains('.') && value == '.') {
      currentStrIdx.value = 1;
    }

    if (value == '.' && text.isEmpty) {
      widget.input.value = '0.';
      currentStrIdx.value = 1;
      if (expressionTokens.isNotEmpty) {
        fullExpression.value = '${expressionTokens.join(' ')} 0.';
      }
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
    if (expressionTokens.isNotEmpty) {
      fullExpression.value = '${expressionTokens.join(' ')} $newText';
    }
  }

  void _setOperator(String op) {
    var currentValue = double.tryParse(widget.input.value) ?? 0.0;

    if (isEvaluated) {
      expressionTokens.clear();
      expressionTokens.addAll([_formatNum(currentValue), op]);
      firstOperand.value = currentValue;
      pendingOperation.value = op;
      resetOnNextDigit = true;
      isEvaluated = false;
      fullExpression.value = expressionTokens.join(' ');
      return;
    }

    if (resetOnNextDigit && expressionTokens.isNotEmpty) {
      expressionTokens[expressionTokens.length - 1] = op;
      pendingOperation.value = op;
      fullExpression.value = expressionTokens.join(' ');
      return;
    }

    if (firstOperand.value != null && pendingOperation.value != null) {
      expressionTokens.addAll([widget.input.value, op]);
      _evaluate(continueWithOperator: op, updateTokens: false);
      fullExpression.value = expressionTokens.join(' ');
    } else {
      expressionTokens.clear();
      expressionTokens.addAll([widget.input.value, op]);
      firstOperand.value = currentValue;
      pendingOperation.value = op;
      resetOnNextDigit = true;
      fullExpression.value = expressionTokens.join(' ');
    }
  }

  void _evaluate({String? continueWithOperator, bool updateTokens = true}) {
    if (firstOperand.value == null || pendingOperation.value == null) return;
    var secondOperand = double.tryParse(widget.input.value) ?? 0.0;
    var op = pendingOperation.value!;
    var result = 0.0;

    switch (op) {
      case '+':
        result = firstOperand.value! + secondOperand;
      case '-':
      case '−':
        result = firstOperand.value! - secondOperand;
      case '×':
      case '*':
        result = firstOperand.value! * secondOperand;
      case '÷':
      case '/':
        result = secondOperand != 0 ? firstOperand.value! / secondOperand : 0.0;
      default:
        result = secondOperand;
    }

    // Round to at most two decimals
    result = double.parse(result.toStringAsFixed(2));

    var formatted = _formatNum(result);

    if (updateTokens) {
      expressionTokens.addAll([widget.input.value, '=']);
      fullExpression.value = expressionTokens.join(' ');
      isEvaluated = true;
    }

    widget.input.value = formatted;
    currentStrIdx.value = newCursorPosition(result.toStringAsFixed(2));

    if (continueWithOperator != null) {
      firstOperand.value = result;
      pendingOperation.value = continueWithOperator;
      resetOnNextDigit = true;
    } else {
      firstOperand.value = null;
      pendingOperation.value = null;
      resetOnNextDigit = false;
    }
  }

  void _delete() {
    if (isEvaluated) {
      expressionTokens.clear();
      fullExpression.value = '';
      isEvaluated = false;
      return;
    }

    if (resetOnNextDigit) {
      // User just pressed an operator (e.g. "5 +") and pressed delete
      if (expressionTokens.isNotEmpty) {
        expressionTokens.removeLast(); // pop operator "+"
      }
      if (expressionTokens.isNotEmpty) {
        var lastOperand = expressionTokens.removeLast(); // pop operand "5"
        widget.input.value = lastOperand;
      }
      resetOnNextDigit = false;

      if (expressionTokens.isNotEmpty) {
        pendingOperation.value = expressionTokens.last;
        var prefixTokens = expressionTokens.sublist(
          0,
          expressionTokens.length - 1,
        );
        firstOperand.value = _computeTokens(prefixTokens);
        fullExpression.value =
            '${expressionTokens.join(' ')} ${widget.input.value}';
      } else {
        firstOperand.value = null;
        pendingOperation.value = null;
        fullExpression.value = '';
      }
      widget.input.refresh();
      currentStrIdx.value = newCursorPosition(
        (double.tryParse(widget.input.value) ?? 0.0).toStringAsFixed(2),
      );
      return;
    }

    var text = widget.input.value;
    if (text.isNotEmpty) {
      if (text == '0') {
        // Current input is already "0": delete preceding operator and restore previous operand
        if (expressionTokens.isNotEmpty) {
          expressionTokens.removeLast(); // pop operator "+"
          if (expressionTokens.isNotEmpty) {
            var lastOperand = expressionTokens.removeLast(); // pop operand "5"
            widget.input.value = lastOperand;
          }
          if (expressionTokens.isNotEmpty) {
            pendingOperation.value = expressionTokens.last;
            var prefixTokens = expressionTokens.sublist(
              0,
              expressionTokens.length - 1,
            );
            firstOperand.value = _computeTokens(prefixTokens);
            fullExpression.value =
                '${expressionTokens.join(' ')} ${widget.input.value}';
          } else {
            firstOperand.value = null;
            pendingOperation.value = null;
            fullExpression.value = '';
          }
          widget.input.refresh();
          currentStrIdx.value = newCursorPosition(
            (double.tryParse(widget.input.value) ?? 0.0).toStringAsFixed(2),
          );
          return;
        }
      } else if (text.length == 1) {
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

      widget.input.refresh();
      if (expressionTokens.isNotEmpty) {
        fullExpression.value =
            '${expressionTokens.join(' ')} ${widget.input.value}';
      } else {
        fullExpression.value = '';
      }
    }
  }

  void _clear() {
    widget.input.value = '0';
    currentStrIdx.value = 3;
    firstOperand.value = null;
    pendingOperation.value = null;
    expressionTokens.clear();
    fullExpression.value = '';
    resetOnNextDigit = false;
    isEvaluated = false;
  }

  Future<void> handleKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      var keyLabel = event.logicalKey.keyLabel;

      if (RegExp(r'^\d$').hasMatch(keyLabel)) {
        _append(keyLabel);
      } else if (keyLabel == '.' || keyLabel == ',') {
        _append('.');
      } else if (keyLabel == '+') {
        _setOperator('+');
      } else if (keyLabel == '-') {
        _setOperator('−');
      } else if (keyLabel == '*' || keyLabel.toLowerCase() == 'x') {
        _setOperator('×');
      } else if (keyLabel == '/') {
        _setOperator('÷');
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          keyLabel == '=') {
        _evaluate();
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
        clipboardText = clipboardText.replaceAll(',', '.').trim();
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

      var expressionText = fullExpression.value;

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
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (expressionText.isNotEmpty)
                      Container(
                        height: 22,
                        alignment: Alignment.centerRight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 4.0,
                              bottom: 2.0,
                            ),
                            child: Text(
                              expressionText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    AnimatedText(
                      inputStringFormattedRev: inputStringFormattedRev,
                      currentStrIdx: currentStrIdx.value,
                    ),
                    8.h,
                    // Operator strip
                    Row(
                      children: [
                        for (var op in ['+', '−', '×', '÷', '='])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: _CalcOperatorButton(
                                label: op,
                                isActive: pendingOperation.value == op,
                                onTap: op == '='
                                    ? _evaluate
                                    : () => _setOperator(op),
                              ),
                            ),
                          ),
                      ],
                    ),
                    6.h,
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

class _CalcOperatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _CalcOperatorButton({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_CalcOperatorButton> createState() => _CalcOperatorButtonState();
}

class _CalcOperatorButtonState extends State<_CalcOperatorButton> {
  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      height: 34,
      child: FilledButton.tonal(
        onPressed: _onTap,
        style: FilledButton.styleFrom(
          backgroundColor: widget.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0.85),
          foregroundColor: widget.isActive
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
          elevation: widget.isActive ? 1 : 0,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
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
      child: FilledButton.tonal(
        onPressed: _onTap,
        style: FilledButton.styleFrom(
          backgroundColor:
              widget.color?.withValues(alpha: 0.16) ??
              context.theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
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
    );
  }
}
