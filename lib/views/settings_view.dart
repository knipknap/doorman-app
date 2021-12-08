import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: 'Application Settings',
      children: [
        SettingsGroup(
          title: 'Hub Settings',
          children: <Widget>[
            TextInputSettingsTile(
              title: 'Hostname',
              settingKey: 'hostname',
              validator: (String? username) {
                if (username == null || username.length > 3) {
                  return null;
                }
                return "Invalid hostname format";
              },
              borderColor: Colors.blueAccent,
              errorColor: Colors.deepOrangeAccent,
            ),
            TextInputSettingsTile(
              title: 'Port number',
              settingKey: 'port',
              enabled: false,
              validator: (String? port) {
                if (port == null || port == "") {
                  return "A port number is required";
                }
                int? portInt = int.tryParse(port);
                if (portInt == null
                 || portInt < 1
                 || portInt > 65536) {
                  return "Invalid port number";
                }
                return null;
              },
              borderColor: Colors.blueAccent,
              errorColor: Colors.deepOrangeAccent,
            ),
          ],
        ),
      ],
    );
  }
}