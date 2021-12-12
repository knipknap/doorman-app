import 'dart:developer' as developer;
import 'package:doorman/screens/load_screen.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/models/main.dart';
import 'package:doorman/components/bezier_container.dart';
import 'package:doorman/components/gradient_button.dart';
import 'package:doorman/components/password_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
    this.title,
    required this.onLoginSuccess,
  }) : super(key: key);

  final String? title;
  final void Function(BuildContext) onLoginSuccess;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loginRunning = false;

  Widget _buildUsernameField(String title, TextEditingController ctr) {
    return TextFormField(
      controller: ctr,
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  void _onLoginPressed() {
    developer.log("LoginScreen._onLoginPressed()");
    MainModel mainModel = Provider.of<MainModel>(context, listen: false);
    setState(() { loginRunning = true; });
    mainModel.client.passwordLogin(
      emailController.text,
      passwordController.text,
      _onLoginSuccess,
      _onLoginError,
    );
  }

  void _onLoginSuccess() {
    developer.log("LoginScreen._onLoginSuccess()");
    setState(() { loginRunning = false; });
    widget.onLoginSuccess(context);
  }

  void _onLoginError(Response response) {
    developer.log("LoginScreen._onLoginError()");
    setState(() { loginRunning = false; });

    // Briefly show the error message.
    String err = response.body;
    if (response.statusCode == 401) {
      err = AppLocalizations.of(context)!.invalidCredentials;
    }
    final snackBar = SnackBar(content: Text(err));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    if (loginRunning) {
      return LoadScreen(status: AppLocalizations.of(context)!.statusLogin);
    }

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _buildTitle(),
                    SizedBox(height: 150),
                    _buildUsernameField(AppLocalizations.of(context)!.email, emailController),
                    SizedBox(height: 10),
                    PasswordFormField(
                      context: context,
                      controller: passwordController,
                      onFieldSubmitted: (_) => _onLoginPressed()
                    ),
                    SizedBox(height: 20),
                    GradientButton(
                      text: AppLocalizations.of(context)!.login,
                      onPressed: _onLoginPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
