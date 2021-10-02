import 'package:controle_de_financas/telaContas/cadastroContas/telaConta.dart';
import 'package:flutter/material.dart';

class BezierApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezier Animation',
      debugShowCheckedModeBanner: false,
      home: AnimationPage(),
    );
  }
}

class AnimationPage extends StatefulWidget {
  AnimationPage({Key key}) : super(key: key);

  @override
  _AnimationPageState createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height *0.25;
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: BezierClipper(),
          child: Container(
            color: aux,
            height: height,
          ),
        ),
      ],
    );
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0, size.width * 0.41); //vertical line//75
    path.quadraticBezierTo(size.width / 2, size.height /50, size.width,
        size.height *0.98); //quadratic curve//71
    path.lineTo(size.width, 0); //vertical line
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
