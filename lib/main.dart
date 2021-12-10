import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart' as constants;
import 'theme.dart';
import 'services/hub_client.dart';
import 'views/door_button_view.dart';
import 'views/hostname_view.dart';
import 'views/login_view.dart';
import 'views/load_screen_view.dart';
import 'views/settings_view.dart';

enum OpenerStates {
  idle,
  starting,
  opening
}

final HubClient client = HubClient();

Future<void> _connect(VoidCallback onInitialized, Function onError) async {
  SharedPreferences.getInstance().then((prefs) {
    String? hostname = prefs.getString('hostname');
    String hubUrl = "http://$hostname:${constants.HUB_PORT}";
    developer.log("_connect() $hubUrl");
    client.init(hubUrl, onInitialized, onError);
  });
}

void pushNamedReplace(navigator, String name, {Object? arguments}) {
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    navigator.pushReplacementNamed(name, arguments: arguments);
  });
}

class GlobalNavigatorObserver extends RouteObserver<ModalRoute<Object?>> implements NavigatorObserver {
  @override
  void didReplace({ Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    developer.log("GlobalNavigatorObserver.didReplace() from $oldRoute to $newRoute");
    if (newRoute == null || newRoute == oldRoute) {
      return;
    }
    didPush(newRoute, oldRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    String prevRouteName = previousRoute == null ? "null" : previousRoute.settings.name as String;
    String? routeName = route.settings.name;
    developer.log("GlobalNavigatorObserver.didPush() from $prevRouteName to $routeName");

    switch (routeName) {
    case "/":
      // Shows load screen.
      //   - if app already initialized (i.e. hostname was set), go to /connect
      //   - if not initialized, go to /init
      SharedPreferences.getInstance().then((prefs) {
        if (prefs.containsKey('hostname')) {
          developer.log("GlobalNavigatorObserver.didPush() pushing /connect");
          pushNamedReplace(route.navigator!, '/connect');
        }
        else {
          developer.log("GlobalNavigatorObserver.didPush() pushing /init");
          pushNamedReplace(route.navigator!, '/init');
        }
      });
      return;

    case "/init":
      // Shows form to enter hostname
      return;

    case "/connect":
      // Shows load screen, attempt to reach hub.
      //   - if reached, go to /login/try
      //   - if not reached, go to /init
      _connect(() {
        developer.log("GlobalNavigatorObserver.didPush() pushing /autologin");
        pushNamedReplace(route.navigator!, '/autologin');
      },
      (response) {
        developer.log("GlobalNavigatorObserver.didPush() error: ${response.statusCode} ${response.body}, pushing /init");
        pushNamedReplace(
          route.navigator!,
          '/init',
          arguments: HostnameViewArguments(response.body),
        );
      });
      return;

    case "/autologin":
      // Shows load screen, check if logged in.
      //   - if already logged in, go straight to /main
      //   - otherwise, go to /login
      if (client.isLoggedIn()) {
        developer.log("GlobalNavigatorObserver.didPush(): Already logged in, going to main");
        pushNamedReplace(route.navigator!, '/main');
        return;
      }

      // Clear navigation history and go to the login form.
      developer.log("GlobalNavigatorObserver.didPush(): Not yet logged in, going to login page");
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        route.navigator!.pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false
        );
        route.navigator!.pushReplacementNamed('/login');
      });
      return;

    case "/login":
      // Shows login form.
      return;
    }
  }
}

final GlobalNavigatorObserver routeObserver = GlobalNavigatorObserver();

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
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OpenerStates opener1State = OpenerStates.idle;
  OpenerStates opener2State = OpenerStates.idle;

  void _showErrorResponse(Response response) {
    // Briefly show the error message as a SnackBar.
    String err = response.body;
    developer.log("_showErrorResponse() $response $err");
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onInitNextPressed(BuildContext context, String hostname) {
    developer.log("_onInitNextPressed");
    SharedPreferences.getInstance().then((prefs) {
      developer.log("_onInitNextPressed() Pushing /connect");
      prefs.setString('hostname', hostname);
      Navigator.pushReplacementNamed(context, '/connect');
      developer.log("_onInitNextPressed() Pushed /connect");
    });
  }

  void _onLoginPressed(BuildContext context, String email, String password) {
    developer.log("Login");
    client.passwordLogin(email,
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

    client.logout(() => { _onLogoutSuccess(context) },
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
    if (actionId == 1) {
      setState(() { opener1State = OpenerStates.starting; });
    }
    if (actionId == 2) {
      setState(() { opener2State = OpenerStates.starting; });
    }

    // Send REST request.
    client.trigger(actionId,
                   () => { _onTriggerSuccess(context, actionId) },
                   (Response response) => { _onTriggerError(context, actionId, response) });
  }

  void _onTriggerSuccess(BuildContext context, int actionId) {
    developer.log("onTriggerSuccess");

    // Set state to "opening" for a few seconds, then back to "idle".
    Duration duration = Duration(seconds: 3);
    if (actionId == 1) {
      setState(() { opener1State = OpenerStates.opening; });
      Timer(duration, () {
        setState(() { opener1State = OpenerStates.idle; });
      });
    }
    if (actionId == 2) {
      setState(() { opener2State = OpenerStates.starting; });
      Timer(duration, () {
        setState(() { opener2State = OpenerStates.idle; });
      });
    }
  }

  void _onTriggerError(BuildContext context, int actionId, Response response) {
    developer.log("onTriggerError");

    // Reset button state.
    if (actionId == 1) {
      setState(() { opener1State = OpenerStates.idle; });
    }
    if (actionId == 2) {
      setState(() { opener2State = OpenerStates.idle; });
    }

    // Briefly show the error message.
    _showErrorResponse(response);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [ routeObserver ],
      title: constants.APP_NAME,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: themeData,
      routes: {
        '/': (context) => LoadScreenView(title: constants.APP_NAME),
        '/init': (context) => HostnameView(onNextPressed: _onInitNextPressed),
        '/connect': (context) => LoadScreenView(
          title: constants.APP_NAME,
          status: AppLocalizations.of(context)!.statusConnecting,
        ),
        '/autologin': (context) => LoadScreenView(
          title: constants.APP_NAME,
          status: AppLocalizations.of(context)!.statusAutologin,
        ),
        '/login': (context) => LoginView(
          title: constants.APP_NAME,
          onLoginPressed: _onLoginPressed
        ),
        '/login/try': (context) => LoadScreenView(
          title: constants.APP_NAME,
          status: AppLocalizations.of(context)!.statusLogin,
        ),
        '/logout/try': (context) => LoadScreenView(
          title: constants.APP_NAME,
          status: AppLocalizations.of(context)!.statusLogout,
        ),
        '/main': (context) => DoorButtonView(
          title: constants.APP_NAME,
          onButtonPressed: _onDoorButtonPressed,
          onSettingsPressed: _onSettingsPressed,
          onLogoutPressed: _onLogoutPressed,
          button1Pulsating: opener1State != OpenerStates.idle,
          button2Pulsating: opener2State != OpenerStates.idle,
        ),
        '/settings': (context) => AppSettings(),
      },
    );
  }
}