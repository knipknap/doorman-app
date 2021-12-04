import 'package:flutter/material.dart';
import 'package:doorman/components/bezier_container.dart';

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

  Widget _buildEntryField(String title, {bool isPassword = false, required TextEditingController ctr}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: ctr,
            obscureText: isPassword,
            decoration: InputDecoration(
                border: InputBorder.none,
                focusColor: Colors.white,
                fillColor: Colors.white,
                filled: true))
        ],
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
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onPressed: () => { widget.onLoginPressed(context, emailController.text, passwordController.text) },
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
        text: 'Doorman',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _buildTitle(),
                  SizedBox(height: 50),
                  _buildEntryField("Email", ctr: emailController),
                  _buildEntryField("Password", ctr: passwordController, isPassword: true),
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
        ],
      ),
    ));
  }
}