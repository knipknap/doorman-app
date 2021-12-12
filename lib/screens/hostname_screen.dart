import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/models/main.dart';
import 'package:doorman/components/bezier_container.dart';
import 'package:doorman/components/gradient_button.dart';
import 'package:provider/provider.dart';

class HostnameScreenArguments {
  final String error;

  HostnameScreenArguments(this.error);
}

class HostnameScreen extends StatefulWidget {
  const HostnameScreen({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  final void Function(BuildContext) onNextPressed;

  @override
  _HostnameScreenState createState() => _HostnameScreenState();
}

class _HostnameScreenState extends State<HostnameScreen> {
  TextEditingController hostnameController = TextEditingController();

  Widget _buildHostnameField(BuildContext context, MainModel mainModel, Widget? child) {
    return TextFormField(
      controller: hostnameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.hostname,
      ),
      onFieldSubmitted: (_) { _onNextPressed(); },
    );
  }

  void _onNextPressed() {
    developer.log("HostnameScreen._onNextButton() next pressed");
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    mainModel.hubHostname = hostnameController.text;
    widget.onNextPressed(context);
    developer.log("HostnameScreen._onNextButton() next pressed done");
  }

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: constants.APP_NAME,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer()),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _buildTitle(),
                  SizedBox(height: 150),
                  Consumer<MainModel>(builder: _buildHostnameField),
                  SizedBox(height: 20),
                  GradientButton(
                    text: AppLocalizations.of(context)!.next,
                    onPressed: _onNextPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
