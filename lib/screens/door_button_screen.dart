import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/components/pulsatingbutton.dart';
import 'package:doorman/models/main.dart';

// This is the type used by the popup menu below.
enum MenuItems { logout, settings }

class DoorButtonScreen extends StatefulWidget {
  const DoorButtonScreen({
    Key? key,
    required this.onSettingsPressed,
    required this.onLogoutPressed,
    this.button1Pulsating = false,
    this.button2Pulsating = false,
  }) : super(key: key);

  final Function onSettingsPressed;
  final Function onLogoutPressed;
  final bool button1Pulsating;
  final bool button2Pulsating;

  @override
  State<DoorButtonScreen> createState() => _DoorButtonScreenState();
}

class _DoorButtonScreenState extends State<DoorButtonScreen> {
  void _showErrorResponse(Response response) {
    // Briefly show the error message as a SnackBar.
    String err = response.body;
    developer.log("DoorButtonScreen._showErrorResponse() $response $err");
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buttonBuilder(BuildContext context,
                        MainModel mainModel,
                        Widget? child,
                        int id,
                        String defaultLabel,
                        double radius) {
    Button button = mainModel.getButton(id);
    return PulsatingButton (
      radius: radius,
      text: button.label ?? defaultLabel,
      pulsating: button.state != ButtonState.idle,
      onTap: (context) => _onButtonPressed(id),
    );
  }

  void _onButtonPressed(int actionId) {
    developer.log("DoorButtonScreen._onButtonPressed()");

    // Update the state of the buttons such that animations start.
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.pushButton(actionId);

    // Send REST request.
    mainModel.client.trigger(
      actionId,
      () => _onTriggerSuccess(actionId),
      (Response response) => _onTriggerError(context, actionId, response),
    );
  }

  void _onTriggerSuccess(int actionId) {
    developer.log("DoorButtonScreen._onTriggerSuccess()");

    // Set state to "opening" for a few seconds, then back to "idle".
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.setButtonState(actionId, ButtonState.opening);

    Duration duration = Duration(seconds: 3);
    Timer(duration, () {
      mainModel.setButtonState(actionId, ButtonState.idle);
    });
  }

  void _onTriggerError(BuildContext context, int actionId, Response response) {
    developer.log("DoorButtonScreen._onTriggerError()");

    // Reset button state.
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.setButtonState(actionId, ButtonState.idle);

    // Briefly show the error message.
    _showErrorResponse(response);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get screen size
    double viewInset = MediaQuery.of(context).viewInsets.bottom;
    double canvasW = size.width*0.8;
    double canvasH = (size.height-viewInset)*0.8;
    double buttonW = canvasW > 600 ? canvasW/2 : canvasW;
    double buttonH = canvasH > 600 ? canvasH/2 : canvasH;
    buttonW = buttonW < buttonH ? buttonW : buttonH;

    PopupMenuButton menuButton = PopupMenuButton<MenuItems>(
      onSelected: (MenuItems result) {
        if (result == MenuItems.settings) {
          widget.onSettingsPressed(context);
        }
        else if (result == MenuItems.logout) {
          widget.onLogoutPressed(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItems>>[
        PopupMenuItem<MenuItems>(
          value: MenuItems.settings,
          child: Text(AppLocalizations.of(context)!.settings),
        ),
        PopupMenuItem<MenuItems>(
          value: MenuItems.logout,
          child: Text(AppLocalizations.of(context)!.logout),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(constants.APP_NAME),
        actions: [ menuButton ],
      ),
      body: Center(
        child: Wrap(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: Consumer<MainModel>(
                builder: (context, mainModel, child) => _buttonBuilder(
                  context,
                  mainModel,
                  child,
                  1,
                  AppLocalizations.of(context)!.button1DefaultLabel,
                  buttonW*0.6
                )
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: Consumer<MainModel>(
                builder: (context, mainModel, child) => _buttonBuilder(
                  context,
                  mainModel,
                  child,
                  2,
                  AppLocalizations.of(context)!.button2DefaultLabel,
                  buttonW*0.6
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}