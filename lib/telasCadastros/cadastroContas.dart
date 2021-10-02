import 'dart:core';
import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/telaConta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:sqflite/sqflite.dart';

class CadastroConta extends StatefulWidget {
  @override
  _CadastroContaState createState() => _CadastroContaState();

  Conta conta;

  CadastroConta({this.conta});
}

class _CadastroContaState extends State<CadastroConta> {
  DatabaseHelper helper = DatabaseHelper();

  final _nomeContaController = TextEditingController();
  final _limiteChequeEspecialContaController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');

  final _nomeContaFocus = FocusNode();
  DateTime now = DateTime.now();

  Conta _contaEditada;

  Color borda = Colors.black;
  var tamanhoBorda1 = Border.all(width: 1.7);
  var tamanhoBorda2 = Border.all(width: 1.7);
  var tamanhoBorda3 = Border.all(width: 1.7);
  var tamanhoBorda4 = Border.all(width: 1.7);
  var tamanhoBorda5 = Border.all(width: 1.7);
  var tamanhoBorda6 = Border.all(width: 1.7);
  var tamanhoBorda7 = Border.all(width: 1.7);
  var tamanhoBorda8 = Border.all(width: 1.7);
  var tamanhoBorda9 = Border.all(width: 1.7);
  var tamanhoBorda10 = Border.all(width: 1.7);
  var tamanhoBorda11 = Border.all(width: 1.7);
  var tamanhoBorda12 = Border.all(width: 1.7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            _contaEditada.nomeConta ??
            "Nova conta",
            style: TextStyle(fontSize: 25.0, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            ),
            TextField(
              maxLength: 15,
              controller: _nomeContaController,
              focusNode: _nomeContaFocus,
              decoration: InputDecoration(labelText: "Nome da Conta"),
              onChanged: (text) {
                setState(() {
                  _contaEditada.nomeConta = text;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
            ),
            TextField(
              controller: _limiteChequeEspecialContaController,
              decoration: InputDecoration(labelText: "Limite Cheque Especial"),
              onChanged: (double) {
                var aux = _limiteChequeEspecialContaController.numberValue;
                if(aux == null){
                  aux = 0.0;
                }
                _contaEditada.limiteChequeEspecialConta = aux;
              },
              keyboardType: TextInputType.number
            ),
            Padding(
              padding: EdgeInsets.all(50.0),
            ),
            Row(
              children: <Widget>[
                Text(
                  "Escolha uma cor para sua conta:",
                  style: TextStyle(fontSize: 25.0),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.purpleAccent,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda6,
                            color: borda,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 6;
                          aux = Colors.purpleAccent;
                          setState(() {
                            tamanhoBorda6 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.limeAccent,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda8,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 8;
                          aux = Colors.limeAccent;
                          setState(() {
                            tamanhoBorda8 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda1,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 1;
                          aux = Colors.red;
                          setState(() {
                            tamanhoBorda1 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda2,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 2;
                          aux = Colors.blue;
                          setState(() {
                            tamanhoBorda2 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.indigo,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda3,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 3;
                          aux = Colors.indigo;
                          setState(() {
                            tamanhoBorda3 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.orange,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda4,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 4;
                          aux = Colors.orange;
                          setState(() {
                            tamanhoBorda4 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                  ],
                ),
                Padding(padding: EdgeInsets.all(30.0),),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda5,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 5;
                          aux = Colors.green;
                          setState(() {
                            tamanhoBorda5 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda7,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 7;
                          aux = Colors.yellow;
                          setState(() {
                            tamanhoBorda7 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.pink,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda9,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 9;
                          aux = Colors.pink;
                          setState(() {
                            tamanhoBorda9 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda10,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 10;
                          aux = Colors.deepPurple;
                          setState(() {
                            tamanhoBorda10 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda11,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 11;
                          aux = Colors.blueGrey;
                          setState(() {
                            tamanhoBorda11 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                            tamanhoBorda12 = Border.all(width: 1.7);
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    ),
                    GestureDetector(
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.brown,
                          ),
                          decoration: BoxDecoration(
                            border: tamanhoBorda12,
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          _contaEditada.idCorConta = 12;
                          aux = Colors.brown;
                          setState(() {
                            tamanhoBorda12 = Border.all(width: 4.0, color: Colors.grey);
                            tamanhoBorda2 = Border.all(width: 1.7);
                            tamanhoBorda3 = Border.all(width: 1.7);
                            tamanhoBorda4 = Border.all(width: 1.7);
                            tamanhoBorda5 = Border.all(width: 1.7);
                            tamanhoBorda1 = Border.all(width: 1.7);
                            tamanhoBorda7 = Border.all(width: 1.7);
                            tamanhoBorda8 = Border.all(width: 1.7);
                            tamanhoBorda9 = Border.all(width: 1.7);
                            tamanhoBorda10 = Border.all(width: 1.7);
                            tamanhoBorda11 = Border.all(width: 1.7);
                            tamanhoBorda6 = Border.all(width: 1.7);
                          });
                        }),
                  ],
                ),
                Padding(padding: EdgeInsets.all(50.0)),
                FlatButton(
                  child: Text("Salvar", style: TextStyle(fontSize: 27.0),),
                  color: Colors.grey,
                  onPressed: () {
                    if(_contaEditada.saldoConta == null){
                      _contaEditada.saldoConta = 0.0;
                      _contaEditada.saldoConta.toString();
                    }
                    if(_contaEditada.limiteChequeEspecialConta == null){
                      _contaEditada.limiteChequeEspecialConta = 0.0;
                      _contaEditada.limiteChequeEspecialConta.toString();
                    }
                    if(_contaEditada.nomeConta != null && _contaEditada.nomeConta.isNotEmpty){
                      _contaEditada.dataConta = now.toString();
                      helper.updateConta(_contaEditada);
                      Navigator.pop(context, _contaEditada);
                    }else{
                      FocusScope.of(context).requestFocus(_nomeContaFocus);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if(widget.conta == null){
      _contaEditada = Conta();
    }else{
      _contaEditada = Conta.fromMap(widget.conta.toMap());

      _nomeContaController.text = _contaEditada.nomeConta;
      _limiteChequeEspecialContaController.updateValue(_contaEditada.limiteChequeEspecialConta);

    }
  }
}
