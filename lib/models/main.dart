import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/services/hub_client.dart';

enum ButtonState {
  idle,
  starting,
  opening
}

class Button extends ChangeNotifier {
  String? _label;
  ButtonState _state = ButtonState.idle;

  String? get label => _label;

  set label(String? value) {
    _label = value;
    notifyListeners();
  }

  ButtonState get state => _state;

  set state(ButtonState value) {
    _state = value;
    notifyListeners();
  }
}

class MainModel extends ChangeNotifier {
  final HubClient client = HubClient();
  String? _hubHostname;
  int _hubPort = constants.HUB_PORT;

  final List<Button> _buttons = [
    Button(),
    Button(),
  ];

  MainModel() {
    for (var button in _buttons) {
      button.addListener(notifyListeners);
    }
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences.getInstance().then((prefs) {
      _hubHostname = prefs.getString("hostname");
      _hubPort = int.tryParse(prefs.getString("port") ?? "x") ?? _hubPort;
      getButton(1).label = prefs.getString("button1-label");
      getButton(2).label = prefs.getString("button2-label");
    });
  }

  String? get hubHostname => _hubHostname;

  set hubHostname(hostname) {
    _hubHostname = hostname != "" ? hostname : null;
    notifyListeners();
  }

  int get hubPort => _hubPort;

  set hubPort(port) {
    _hubPort = port;
    notifyListeners();
  }

  String get hubUrl {
    return "http://$hubHostname:$hubPort";
  }

  void setButtonLabel(int id, String label) {
    _buttons[id-1].label = label;
  }

  void setButtonState(int id, ButtonState state) {
    _buttons[id-1].state = state;
  }

  void pushButton(int id) {
    setButtonState(id, ButtonState.opening);
  }

  Button getButton(int id) {
    return _buttons[id-1];
  }
}
