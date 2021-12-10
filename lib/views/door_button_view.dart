import 'package:doorman/models/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/components/pulsatingbutton.dart';
import 'package:provider/provider.dart';

// This is the type used by the popup menu below.
enum MenuItems { logout, settings }

class DoorButtonView extends StatefulWidget {
  const DoorButtonView({
    Key? key,
    required this.title,
    required this.onButtonPressed,
    required this.onSettingsPressed,
    required this.onLogoutPressed,
    this.button1Pulsating = false,
    this.button2Pulsating = false,
  }) : super(key: key);

  final String title;
  final Function onButtonPressed;
  final Function onSettingsPressed;
  final Function onLogoutPressed;
  final bool button1Pulsating;
  final bool button2Pulsating;

  @override
  State<DoorButtonView> createState() => _DoorButtonViewState();
}

class _DoorButtonViewState extends State<DoorButtonView> {
  Widget _button1Builder(BuildContext context, MainModel mainModel, Widget? child) {
    Button button = mainModel.getButton(1);
    String defaultLabel = AppLocalizations.of(context)!.button1DefaultLabel;
    return PulsatingButton (
      text: button.label ?? defaultLabel,
      pulsating: button.state != ButtonState.idle,
      onTap: (context) {
        mainModel.pushButton(1);
        widget.onButtonPressed(context, 1);
      },
    );
  }

  Widget _button2Builder(BuildContext context, MainModel mainModel, Widget? child) {
    Button button = mainModel.getButton(2);
    String defaultLabel = AppLocalizations.of(context)!.button2DefaultLabel;
    return PulsatingButton (
      text: button.label ?? defaultLabel,
      pulsating: button.state != ButtonState.idle,
      onTap: (context) {
        mainModel.pushButton(2);
        widget.onButtonPressed(context, 2);
      },
    );
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
        title: Text(widget.title),
        actions: [ menuButton ],
      ),
      body: Center(
        child: Wrap(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: Consumer<MainModel>(builder: _button1Builder),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: Consumer<MainModel>(builder: _button2Builder),
            ),
          ],
        ),
      ),
    );
  }
}