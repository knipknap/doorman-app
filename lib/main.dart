import 'dart:async';
import 'dart:developer' as developer;
import 'package:doorman_flutter/constants.dart' as constants;
import 'package:doorman_flutter/services/hub_client.dart';
import 'package:doorman_flutter/views/door_button_view.dart';
import 'package:doorman_flutter/views/login_view.dart';
import 'package:doorman_flutter/views/login_wait_view.dart';
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
  final HubClient client = HubClient(constants.DOORMAN_URL);
  OpenerStates opener1State = OpenerStates.idle;
  OpenerStates opener2State = OpenerStates.idle;

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
      //home: LoginView(title: 'Doorman', onLoginPressed: _onLoginPressed),
      routes: {
        '/': (context) => LoginView(title: constants.APP_NAME, onLoginPressed: _onLoginPressed),
        '/login/try': (context) => LoginWaitView(title: constants.APP_NAME),
        '/main': (context) => DoorButtonView(
          title: constants.APP_NAME,
          onButtonPressed: _onDoorButtonPressed,
          button1Pulsating: opener1State != OpenerStates.idle,
          button2Pulsating: opener2State != OpenerStates.idle,
        ),
      },
    );
  }
}