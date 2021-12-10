import 'package:flutter/widgets.dart';

enum ButtonState {
  idle,
  starting,
  opening
}

class Button {
  String? label;
  ButtonState state = ButtonState.idle;
}

class MainModel extends ChangeNotifier {
  final List<Button> _buttons = [
    Button(),
    Button(),
  ];

  void setButtonState(int id, ButtonState state) {
    _buttons[id-1].state = state;
    notifyListeners();
  }

  void pushButton(int id) {
    setButtonState(id, ButtonState.opening);
  }

  Button getButton(int id) {
    return _buttons[id-1];
  }
}
