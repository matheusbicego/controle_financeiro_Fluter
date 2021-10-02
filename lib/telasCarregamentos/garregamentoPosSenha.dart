import 'package:controle_de_financas/telaContas/cadastroContas/listaContas.dart';
import 'package:flutter/material.dart';

class CarregamentoPosSenha extends StatefulWidget {
  @override
  _CarregamentoPosSenhaState createState() => _CarregamentoPosSenhaState();
}

class _CarregamentoPosSenhaState extends State<CarregamentoPosSenha> {

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _confereFuncoes();
  }

  Future<void> _confereFuncoes() async{
    if(flag == true){
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MostraContas()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fazTela(),
    );
  }

  Widget fazTela(){
      return Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 350.0),),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
  }
}
