import 'dart:async';
import 'dart:developer' as developer;
import 'package:doorman/models/main.dart';
import 'package:doorman/screens/connection_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart' as constants;
import 'theme.dart';
import 'screens/door_button_screen.dart';
import 'screens/login_screen.dart';
import 'screens/load_screen.dart';
import 'screens/my_settings_screen.dart';

final mainModel = MainModel();

void main() {
  initSettings().then((_) {
    runApp(
      MyApp()
    );
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
  await mainModel.loadSharedPreferences();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _onConnected(BuildContext context, bool haveSessionID) {
    developer.log("_onConnected() $context $haveSessionID");
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('hostname', mainModel.hubHostname ?? "");
      prefs.setString('port', mainModel.hubPort.toString());

      if (mainModel.client.isLoggedIn()) {
        developer.log("_onConnected() ${mainModel.hubHostname} Pushing /main");
        Navigator.pushReplacementNamed(context, '/main');
        developer.log("_onConnected() Pushed /main");
      }
      else {
        developer.log("_onConnected() ${mainModel.hubHostname} Pushing /login");
        Navigator.pushReplacementNamed(context, '/login');
        developer.log("_onConnected() Pushed /login");
      }
    });
  }

  void _onLoginSuccess(BuildContext context) {
    developer.log("_onLoginSuccess()");
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _onLogoutPressed(BuildContext context) {
    developer.log("_onLogoutPressed()");

    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.client.logout(
      () => _onLogoutSuccess(context),
      (Response response) => _onLogoutError(context, response),
    );

    Navigator.pushNamed(context, '/logout/try');
  }

  void _onLogoutSuccess(BuildContext context) {
    developer.log("_onLogoutSuccess()");

    // Clear navigation history and go to the login form.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false
    );
  }

  void _onLogoutError(BuildContext context, Response response) {
    developer.log("_onLogoutError()");

    // Clear navigation history and go to the login form.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false
    );

    // Briefly show the error message.
    final snackBar = SnackBar(content: Text(response.body));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onSettingsPressed(BuildContext context) {
    developer.log("_onSettingsPressed");
    Navigator.pushNamed(context, '/settings');
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => mainModel,
      child: MaterialApp(
        title: constants.APP_NAME,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeData,
        routes: {
          '/': (context) => ConnectionScreen(onConnected: _onConnected),
          '/login': (context) => LoginScreen(
            title: constants.APP_NAME,
            onLoginSuccess: _onLoginSuccess
          ),
          '/login/try': (context) => LoadScreen(
            title: constants.APP_NAME,
            status: AppLocalizations.of(context)!.statusLogin,
          ),
          '/logout/try': (context) => LoadScreen(
            title: constants.APP_NAME,
            status: AppLocalizations.of(context)!.statusLogout,
          ),
          '/main': (context) => DoorButtonScreen(
            onSettingsPressed: _onSettingsPressed,
            onLogoutPressed: _onLogoutPressed,
          ),
          '/settings': (context) => MySettingsScreen(),
        },
      ),
    );
  }
}