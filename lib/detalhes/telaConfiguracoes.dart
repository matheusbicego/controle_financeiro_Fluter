import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudUsuario.dart';
import 'package:flutter/material.dart';


class MostraConfiguracoes extends StatefulWidget {
  @override
  _MostraConfiguracoesState createState() => _MostraConfiguracoesState();
}

class _MostraConfiguracoesState extends State<MostraConfiguracoes> {
  DatabaseHelper helper = DatabaseHelper();
  List<Usuario> usuario = List();

  final _nomeUsuarioController = TextEditingController();
  final _senhaUsuarioController = TextEditingController();

  bool flag = true;


  @override
  void initState() {
    super.initState();
    _getAllUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Configurações",
            style: TextStyle(fontSize: 25.0, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: mostraOpcoes(),
    );
  }

  Widget mostraOpcoes(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TextFormField(
            maxLength: 50,
            controller: _nomeUsuarioController,
            decoration: InputDecoration(
                labelText: "Seu nome",
                prefixIcon:Icon(Icons.account_circle)),
            onChanged: (text) {
              setState(() {
                usuario[0].nomeUsuario = text;
              });
            },
          ),
          TextFormField(
            obscureText: flag,
            controller: _senhaUsuarioController,
            decoration: InputDecoration(
                labelText: "Sua senha",
                prefixIcon:Icon(Icons.vpn_key),
                suffixIcon:IconButton(icon: Icon(Icons.remove_red_eye),
                  onPressed: (){
                    setState(() {
                      if(flag){
                        flag = false;
                      }else{
                        flag = true;
                      }
                    });
                  },) ),
            onChanged: (text) {
              setState(() {
                usuario[0].senhaUsuario = text;
              });
            },
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  value: usuario[0].salvaSenha,
                  onChanged:(value){
                    setState(() {
                      usuario[0].salvaSenha = value;
                    });
                  }
              ),
              Text("Não perguntar senha novamente ",style: TextStyle(fontSize: 14.874),),
            ],
          ),
          Padding(padding: EdgeInsets.all(150.0),),
          FlatButton(
            child: Text(
              "Salvar",
              style: TextStyle(fontSize: 27.0),
            ),
            color: Colors.grey,
            onPressed: () {
              helper.updateUsuario(usuario[0]);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }



  Future<void> _getAllUsuarios() async {
    await helper.getAllUsuarios().then((list) {
      setState(() {
        usuario = list;
        _nomeUsuarioController.text = usuario[0].nomeUsuario;
        _senhaUsuarioController.text = usuario[0].senhaUsuario;
      });
    });
  }
}
