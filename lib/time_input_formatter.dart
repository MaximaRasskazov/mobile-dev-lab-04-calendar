import 'package:flutter/services.dart';

TextEditingValue formatTimeInput(
  TextEditingValue oldValue,
  TextEditingValue newValue,
) {
  final text = newValue.text;
  if (text.contains(':')) {
    return newValue;
  }
  // После двух введённых цифр добавляем двоеточие.
  // При удалении символов оно не должно появляться снова.
  if (text.length == 2 && oldValue.text.length < 2) {
    return TextEditingValue(
      text: '$text:',
      selection: const TextSelection.collapsed(offset: 3),
    );
  }
  // Поддерживаем вставку сразу четырёх цифр, например 1230.
  if (text.length == 4) {
    return TextEditingValue(
      text: '${text.substring(0, 2)}:${text.substring(2)}',
      selection: const TextSelection.collapsed(offset: 5),
    );
  }
  return newValue;
}
