import 'package:flutter/material.dart';
import 'package:doorman/constants.dart' as constants;
import 'package:doorman/components/bezier_container.dart';

class HostnameViewArguments {
  final String error;

  HostnameViewArguments(this.error);
}

class HostnameView extends StatefulWidget {
  const HostnameView({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  final Function onNextPressed;

  @override
  _HostnameViewState createState() => _HostnameViewState();
}

class _HostnameViewState extends State<HostnameView> {
  TextEditingController hostnameController = TextEditingController();

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

  Widget _buildNextButton(BuildContext context) {
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
          'Next',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onPressed: () => { widget.onNextPressed(context, hostnameController.text) },
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
    final args = ModalRoute.of(context)!.settings.arguments as HostnameViewArguments?;

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
                  _buildEntryField("Hostname", ctr: hostnameController),
                  SizedBox(height: 20),
                  _buildNextButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}