import 'package:doorman/models/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  Widget _buttonLabelTileBuilder(BuildContext context,
                                 MainModel mainModel,
                                 Widget? child,
                                 int id,
                                 String settingsKey,
                                 String defaultValue) {
    Button button = mainModel.getButton(id);
    return TextInputSettingsTile(
      title: AppLocalizations.of(context)!.buttonLabel(id),
      initialValue: button.label ?? defaultValue,
      settingKey: settingsKey,
      validator: (String? label) {
        if (label != null && label.length < 20) {
          return null;
        }
        return AppLocalizations.of(context)!.errLabelTooLong;
      },
      onChange: (text) {
        button.label = text;
      },
    );
  }

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
            ),
          ],
        ),

        SettingsGroup(
          title: AppLocalizations.of(context)!.buttonSettings,
          children: <Widget>[
            Consumer<MainModel>(
              builder: (context, mainModel, child) => _buttonLabelTileBuilder(
                context,
                mainModel,
                child,
                1,
                'button1-label',
                AppLocalizations.of(context)!.button1DefaultLabel
              ),
            ),
            Consumer<MainModel>(
              builder: (context, mainModel, child) => _buttonLabelTileBuilder(
                context,
                mainModel,
                child,
                2,
                'button2-label',
                AppLocalizations.of(context)!.button2DefaultLabel
              )
            ),
          ],
        ),
      ],
    );
  }
}