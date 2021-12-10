import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doorman/components/bezier_container.dart';
import 'package:doorman/constants.dart' as constants;

class LoginView extends StatefulWidget {
  const LoginView({
    Key? key,
    this.title,
    required this.onLoginPressed,
  }) : super(key: key);

  final String? title;
  final Function onLoginPressed;

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  Widget _buildPasswordField(String title, TextEditingController ctr) {
    return TextFormField(
      controller: ctr,
      obscureText: true,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) {
        widget.onLoginPressed(context, emailController.text, passwordController.text);
      },
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

  /*
  Widget _buildAccountLabel() {
    return InkWell(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage())
        );*/
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
  */

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
                    _buildPasswordField(AppLocalizations.of(context)!.password, passwordController),
                    SizedBox(height: 20),
                    _buildLoginButton(context),
                    /*Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.centerRight,
                      child: Text('Forgot Password ?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(height: height * .055),
                    _buildAccountLabel(),
                    */
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