import 'dart:async';
import 'dart:developer' as developer;
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/services/hub_client.dart';
import 'package:doorman/views/door_button_view.dart';
import 'package:doorman/views/login_view.dart';
import 'package:doorman/views/login_wait_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

enum OpenerStates {
  idle,
  starting,
  opening
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BuildContext? bcontext;
  late final HubClient client;
  OpenerStates opener1State = OpenerStates.idle;
  OpenerStates opener2State = OpenerStates.idle;

  _MyAppState() {
    developer.log("_MyAppState()");
    client = HubClient(constants.DOORMAN_URL);
    client.init(_onClientInitialized, _onInitializationError);
    developer.log("_MyAppState() done");
  }

  void _onClientInitialized() {
    developer.log("_onClientInitialized");
    if (client.isLoggedIn()) {
      developer.log("_onClientInitialized(): Already logged in, going straight to main");
      Navigator.pushReplacementNamed(bcontext!, '/main');
    }
    else {
      developer.log("_onClientInitialized(): Not yet logged in, going to login page");
      Navigator.pushReplacementNamed(bcontext!, '/login');
    }
  }

  void _onInitializationError(Response response) {
    developer.log("_onInitializationError");

    // Clear navigation history and go to the login form.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false
    );

    // Briefly show the error message.
    String err = response.body;
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      err = "Invalid credentials, please try again.";
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
    String err = response.body;
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onSettingsPressed(BuildContext context) {
    developer.log("_onSettingsPressed");
    //TODO: Navigator.pushNamed(context, '/settings');
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
    final snackBar = SnackBar(content: Text(response.body));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: constants.APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        '/': (context) {
          bcontext = context;
          return LoginWaitView(title: constants.APP_NAME);
        },
        '/login': (context) => LoginView(title: constants.APP_NAME, onLoginPressed: _onLoginPressed),
        '/login/try': (context) => LoginWaitView(title: constants.APP_NAME),
        '/logout/try': (context) => LoginWaitView(title: constants.APP_NAME),
        '/main': (context) => DoorButtonView(
          title: constants.APP_NAME,
          onButtonPressed: _onDoorButtonPressed,
          onSettingsPressed: _onSettingsPressed,
          onLogoutPressed: _onLogoutPressed,
          button1Pulsating: opener1State != OpenerStates.idle,
          button2Pulsating: opener2State != OpenerStates.idle,
        ),
      },
    );
  }
}