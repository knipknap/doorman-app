import 'dart:developer' as developer;
import 'package:doorman_flutter/components/pulsatingbutton.dart';
import 'package:flutter/material.dart';

class DoorButtonView extends StatefulWidget {
  const DoorButtonView({
    Key? key,
    required this.title,
    required this.onButtonPressed,
    this.button1Pulsating = false,
    this.button2Pulsating = false,
  }) : super(key: key);

  final String title;
  final Function onButtonPressed;
  final bool button1Pulsating;
  final bool button2Pulsating;

  @override
  State<DoorButtonView> createState() => _DoorButtonViewState();
}

class _DoorButtonViewState extends State<DoorButtonView> {
  void _onMenuPressed() {
    developer.log("Menu");
  }

  void _onButton1Pressed(BuildContext context) {
    developer.log("Button1");
    widget.onButtonPressed(context, 1);
  }

  void _onButton2Pressed(BuildContext context) {
    developer.log("Button2");
    widget.onButtonPressed(context, 2);
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _onMenuPressed, icon: const Icon(Icons.menu)),
        ],
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: PulsatingButton (
                text: "Gate\n+\nFront Door",
                pulsating: widget.button1Pulsating,
                onTap: (context) { _onButton1Pressed(context); },
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(width: buttonW, height: buttonW),
              child: PulsatingButton (
                text: "Apartment",
                pulsating: widget.button2Pulsating,
                onTap: (context) { _onButton2Pressed(context); },
              ),
            ),
          ],
        ),
      ),
    );
  }
}