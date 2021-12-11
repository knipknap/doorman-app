import 'dart:developer' as developer;
import 'package:doorman/models/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/components/bezier_container.dart';
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
      onFieldSubmitted: (text) {
        developer.log("HostnameScreen._buildNextButton() enter to submit pressed");
        mainModel.hubHostname = hostnameController.text;
        widget.onNextPressed(context);
        developer.log("HostnameScreen._buildNextButton() enter to submit done");
      }
    );
  }

  Widget _buildNextButton(BuildContext context, MainModel mainModel, Widget? child) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
      child: Ink(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [Color(0xfffbb448), Color(0xfff7892b)],
          )
        ),
        child: Text(
          AppLocalizations.of(context)!.next,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onPressed: () {
        developer.log("HostnameScreen._buildNextButton() next pressed");
        mainModel.hubHostname = hostnameController.text;
        widget.onNextPressed(context);
        developer.log("HostnameScreen._buildNextButton() next pressed done");
      }
    );
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as HostnameScreenArguments?;

    if (args != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final snackBar = SnackBar(content: Text(args.error));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
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
                  Consumer<MainModel>(builder: _buildNextButton),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}