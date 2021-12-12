import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/models/main.dart';
import 'package:doorman/screens/load_screen.dart';
import 'package:doorman/screens/hostname_screen.dart';

class ConnectionScreen extends StatefulWidget with RouteAware {
  const ConnectionScreen({
    Key? key,
    required this.onConnected,
  }) : super(key: key);

  final void Function(BuildContext, bool) onConnected;

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with TickerProviderStateMixin {
  void _tryInit() {
    developer.log("ConnectionScreen._tryInit()");

    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    if (mainModel.hubHostname == null) {
      developer.log("ConnectionScreen._tryInit() hostname not set}");
      return;
    }

    mainModel.client.init(
      mainModel.hubUrl,
      () {
        bool isLoggedIn = mainModel.client.isLoggedIn();
        developer.log("ConnectionScreen._tryInit() logged in. Have a sid? $isLoggedIn");
        widget.onConnected(context, isLoggedIn);
      },
      (response) {
        developer.log("ConnectionScreen._tryInit() login error: ${response.statusCode} ${response.body}");
        setState(() {
          // Also triggers this widget to be rebuilt, thus showing the hostname form.
          mainModel.hubHostname = null;
        });
        final snackBar = SnackBar(content: Text(response.body));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    );
  }

  @override
  void initState() {
    super.initState();
    developer.log("ConnectionScreen.initState()");
    _tryInit();
  }

  void didPop() {
    developer.log("ConnectionScreen.didPop()");
    _tryInit();
  }

  void didPush() {
    developer.log("ConnectionScreen.didPush()");
    _tryInit();
  }

  @override
  Widget build(BuildContext context) {
    developer.log("ConnectionScreen.build()");
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);

    if (mainModel.hubHostname != null) {
      developer.log("ConnectionScreen.build() hostname already set ${mainModel.hubHostname}");
      return LoadScreen(
        title: constants.APP_NAME,
        status: AppLocalizations.of(context)!.statusConnecting,
      );
    }

    return HostnameScreen(onNextPressed: (_) => _tryInit());
  }
}