import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/components/bezier_container.dart';
import 'package:doorman/components/password_form_field.dart';
import 'package:doorman/constants.dart' as constants;

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
    this.title,
    required this.onLoginPressed,
  }) : super(key: key);

  final String? title;
  final Function onLoginPressed;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget _buildUsernameField(String title, TextEditingController ctr) {
    return TextFormField(
      controller: ctr,
      autofillHints: const [AutofillHints.username],
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
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
          AppLocalizations.of(context)!.login,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onPressed: () {
        widget.onLoginPressed(context, emailController.text, passwordController.text);
      },
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
  Widget build(BuildContext context) {
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
                      onFieldSubmitted: (_) {
                        widget.onLoginPressed(context, emailController.text, passwordController.text);
                      },
                    ),
                    SizedBox(height: 20),
                    _buildLoginButton(context),
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
