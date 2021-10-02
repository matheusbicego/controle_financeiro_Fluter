import 'dart:async';
import 'dart:core';
import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudUsuario.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaContas.dart';
import 'package:controle_de_financas/telasCarregamentos/garregamentoPosSenha.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  DatabaseHelper helper = DatabaseHelper();
  List<Usuario> usuario = List();
  Usuario _usuarioCriado = Usuario();

  final _nomeUsuarioController = TextEditingController();
  final _nomeUsuarioFocus = FocusNode();

  final _senhaUsuarioController = TextEditingController();
  final _senhaUsuarioFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();


  bool flag = true;
  String senhaTemp;


  @override
  void initState() {
    super.initState();
    _getAllUsuarios();
    if (_usuarioCriado.salvaSenha == null) {
      _usuarioCriado.salvaSenha = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              _criaTelaLogin(),
            ],
          ),
      ),
    );
  }

  Widget _criaTelaLogin() {
    if (usuario.length == 0) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(30.0, 250.0, 30.0, 7.0),
          ),
          Row(
            children: <Widget>[
              Text(
                "Ola, cadastre-se",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextFormField(
            maxLength: 50,
            controller: _nomeUsuarioController,
            focusNode: _nomeUsuarioFocus,
            decoration: InputDecoration(
                labelText: "Seu nome", prefixIcon: Icon(Icons.account_circle)),
            onChanged: (text) {
              setState(() {
                _usuarioCriado.nomeUsuario = text;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
          ),
          TextFormField(
            obscureText: flag,
            controller: _senhaUsuarioController,
            focusNode: _senhaUsuarioFocus,
            decoration: InputDecoration(
                labelText: "Cria uma senha",
                prefixIcon: Icon(Icons.vpn_key),
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    setState(() {
                      if (flag) {
                        flag = false;
                      } else {
                        flag = true;
                      }
                    });
                  },
                )),
            onChanged: (text) {
              setState(() {
                _usuarioCriado.senhaUsuario = text;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  value: _usuarioCriado.salvaSenha,
                  onChanged: (value) {
                    setState(() {
                      _usuarioCriado.salvaSenha = value;
                    });
                  }),
              Text(
                "Não perguntar senha novamente ",
                style: TextStyle(fontSize: 14.874),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 60.0),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.09,
            child: FlatButton(
              child: Text("Criar",
                  style:
                      TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              color: Colors.grey,
              onPressed: () {
                salvaUsuario();
                mudaTela();
              },
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 230.0, 30.0, 7.0),
              ),
              Wrap(
                children: <Widget>[
                  Text(
                    "Ola, ${usuario[0].nomeUsuario}",
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  obscureText: flag,
                  controller: _senhaUsuarioController,
                  focusNode: _senhaUsuarioFocus,
                  decoration: InputDecoration(
                      labelText: "Digite sua senha",
                      prefixIcon: Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: () {
                          setState(() {
                            if (flag) {
                              flag = false;
                            } else {
                              flag = true;
                            }
                          });
                        },
                      )),
                  onChanged: (text) {},
                  validator: (text) {
                    if (text != usuario[0].senhaUsuario) {
                      FocusScope.of(context).requestFocus(_senhaUsuarioFocus);
                      return "Senha incorreta";
                    }
                    return null;
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                      value: usuario[0].salvaSenha,
                      onChanged: (value) {
                        setState(() {
                          usuario[0].salvaSenha = value;
                        });
                      }),
                  Text(
                    "Não perguntar senha novamente ",
                    style: TextStyle(fontSize: 14.874),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 60.0),
              ),
            ],
          ),
         Center(
           child:Column(
             children: <Widget>[
               Padding(
                 padding: EdgeInsets.only(top: 530.0),
               ),
               Container(
                 width: MediaQuery.of(context).size.width * 0.3,
                 height: MediaQuery.of(context).size.height * 0.09,
                 child: FlatButton(
                   child: Text("Entrar",
                       style: TextStyle(
                           fontSize: 30.0, fontWeight: FontWeight.bold)),
                   color: Colors.grey,
                   onPressed: () {
                     validaUsuario();
                   },
                 ),
               ),
             ],
           ),
         ),
        ],
      );
    }
  }

  Future<void> salvaUsuario() async {
    await helper.saveUsuario(_usuarioCriado);
  }

  void validaUsuario() {
    if (_formKey.currentState.validate()) {
      helper.updateUsuario(usuario[0]);
      mudaTela();
    }
  }

  void mudaTela() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MostraContas()));
  }

  Future<void> _getAllUsuarios() async {
    await helper.getAllUsuarios().then((list) {
      setState(() {
        usuario = list;
        if(usuario.isNotEmpty){
          if (usuario[0].salvaSenha == true) {
            _senhaUsuarioController.text = usuario[0].senhaUsuario;
          }
        }
      });
    });
  }
}
