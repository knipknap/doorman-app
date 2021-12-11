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
  void _showErrorResponse(Response response) {
    // Briefly show the error message as a SnackBar.
    String err = response.body;
    developer.log("_showErrorResponse() $response $err");
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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

  void _onLoginPressed(BuildContext context, String email, String password) {
    developer.log("Login");
    mainModel.client.passwordLogin(email,
                         password,
                         () => { _onLoginSuccess(context) },
                         (Response response) => { _onLoginError(context, response) });
    Navigator.pushNamed(context, '/login/try');
  }

  void _onLoginSuccess(BuildContext context) {
    developer.log("LoginSuccess");
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _onLoginError(BuildContext context, Response response) {
    developer.log("onLoginError");

    Navigator.pop(context);

    // Briefly show the error message.
    String err = response.body;
    if (response.statusCode == 401) {
      err = AppLocalizations.of(context)!.invalidCredentials;
    }
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onLogoutPressed(BuildContext context) {
    developer.log("_onLogoutPressed");

    mainModel.client.logout(() => { _onLogoutSuccess(context) },
                  (Response response) => { _onLogoutError(context, response) });

    Navigator.pushNamed(context, '/logout/try');
  }

  void _onLogoutSuccess(BuildContext context) {
    developer.log("LogoutSuccess");

    // Clear navigation history and go to the login form.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false
    );
  }

  void _onLogoutError(BuildContext context, Response response) {
    developer.log("onLogoutError");

    // Clear navigation history and go to the login form.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false
    );

    // Briefly show the error message.
    _showErrorResponse(response);
  }

  void _onSettingsPressed(BuildContext context) {
    developer.log("_onSettingsPressed");
    Navigator.pushNamed(context, '/settings');
  }

  void _onDoorButtonPressed(BuildContext context, int actionId) {
    developer.log("onDoorButtonPressed");

    // Update the state of the buttons such that animations start.
    Provider.of<MainModel>(context, listen: false).pushButton(actionId);

    // Send REST request.
    mainModel.client.trigger(actionId,
                   () => { _onTriggerSuccess(context, actionId) },
                   (Response response) => { _onTriggerError(context, actionId, response) });
  }

  void _onTriggerSuccess(BuildContext context, int actionId) {
    developer.log("onTriggerSuccess");

    // Set state to "opening" for a few seconds, then back to "idle".
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.setButtonState(actionId, ButtonState.opening);

    Duration duration = Duration(seconds: 3);
    Timer(duration, () {
        mainModel.setButtonState(actionId, ButtonState.idle);
    });
  }

  void _onTriggerError(BuildContext context, int actionId, Response response) {
    developer.log("onTriggerError");

    // Reset button state.
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.setButtonState(actionId, ButtonState.idle);

    // Briefly show the error message.
    _showErrorResponse(response);
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
            onLoginPressed: _onLoginPressed
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
            title: constants.APP_NAME,
            onButtonPressed: _onDoorButtonPressed,
            onSettingsPressed: _onSettingsPressed,
            onLogoutPressed: _onLogoutPressed,
          ),
          '/settings': (context) => MySettingsScreen(),
        },
      ),
    );
  }
}