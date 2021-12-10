import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      title: AppLocalizations.of(context)!.appSettings,
      children: [
        SettingsGroup(
          title: AppLocalizations.of(context)!.hubSettings,
          children: <Widget>[
            TextInputSettingsTile(
              title: AppLocalizations.of(context)!.hostname,
              settingKey: 'hostname',
              validator: (String? hostname) {
                if (hostname != null && hostname.length > 3) {
                  return null;
                }
                return AppLocalizations.of(context)!.errInvalidHostname;
              },
              borderColor: Colors.blueAccent,
              errorColor: Colors.deepOrangeAccent,
            ),
            TextInputSettingsTile(
              title: AppLocalizations.of(context)!.portNumber,
              settingKey: 'port',
              enabled: false,
              validator: (String? port) {
                if (port == null || port == "") {
                  return AppLocalizations.of(context)!.errMissingPortNumber;
                }
                int? portInt = int.tryParse(port);
                if (portInt == null
                 || portInt < 1
                 || portInt > 65536) {
                  return AppLocalizations.of(context)!.errInvalidPortNumber;
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