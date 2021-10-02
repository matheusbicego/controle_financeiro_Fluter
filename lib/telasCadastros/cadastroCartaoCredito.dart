import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CadastroCartaoCredito extends StatefulWidget {
  @override
  _CadastroCartaoCreditoState createState() => _CadastroCartaoCreditoState();

  Conta conta;
  CartaoCredito cartaoCredito;

  CadastroCartaoCredito({this.conta, this.cartaoCredito});
}

class _CadastroCartaoCreditoState extends State<CadastroCartaoCredito> {
  DatabaseHelper helper = DatabaseHelper();

  final _nomeCartaoCreditoController = TextEditingController();
  final _nomeCartaoCreditoFocus = FocusNode();

  CartaoCredito _cartaoCreditoEditada;
  Conta _contaSelecionada;
  DateTime selectedDate = DateTime.now();
  final _dataInicioFocus = FocusNode();

  void initState() {
    super.initState();
    _cartaoCreditoEditada = CartaoCredito();
    _contaSelecionada = Conta.fromMap(widget.conta.toMap());

    if(widget.cartaoCredito == null){
      _cartaoCreditoEditada = CartaoCredito();
    }else{
      _cartaoCreditoEditada = CartaoCredito.fromMap(widget.cartaoCredito.toMap());

      _nomeCartaoCreditoController.text = _cartaoCreditoEditada.nomeCartaoCredito;
    }
    _decideCor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            _cartaoCreditoEditada.nomeCartaoCredito ??
                "Novo Cartão de credito",
            style: TextStyle(fontSize: 25.0, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text("Conta: ${_contaSelecionada.nomeConta}", style: TextStyle(fontSize: 25.0, color: _contaSelecionada.corConta),),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            ),
            TextField(
              maxLength: 30,
              controller: _nomeCartaoCreditoController,
              focusNode: _nomeCartaoCreditoFocus,
              decoration: InputDecoration(labelText: "Nome da Conta de Credito"),
              onChanged: (text) {
                setState(() {
                  _cartaoCreditoEditada.nomeCartaoCredito = text;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
            ),
            Padding(padding: EdgeInsets.all(80.0),),
            FlatButton(
              child: Text(
                "Salvar",
                style: TextStyle(fontSize: 27.0),
              ),
              color: Colors.grey,
              onPressed: () {
                if(_cartaoCreditoEditada.nomeCartaoCredito != null && _cartaoCreditoEditada.nomeCartaoCredito.isNotEmpty){
                      if(selectedDate != null){
                        String formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);
                        _cartaoCreditoEditada.dataInicioCartaoCredito = formattedDate.toString();
                        _cartaoCreditoEditada.idConta = _contaSelecionada.idConta;
                        Navigator.pop(context, _cartaoCreditoEditada);
                      }else{
                        FocusScope.of(context)
                            .requestFocus(_dataInicioFocus);
                      }
                }else{
                  FocusScope.of(context)
                      .requestFocus(_nomeCartaoCreditoFocus);
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  void _decideCor() {
    setState(() {
      switch (_contaSelecionada.idCorConta) {
        case 1:
          {
            _contaSelecionada.corConta = Colors.red;
          }
          break;
        case 2:
          {
            _contaSelecionada.corConta = Colors.blue;
          }
          break;
        case 3:
          {
            _contaSelecionada.corConta = Colors.indigo;
          }
          break;
        case 4:
          {
            _contaSelecionada.corConta = Colors.orange;
          }
          break;
        case 5:
          {
            _contaSelecionada.corConta = Colors.green;
          }
          break;
        case 6:
          {
            _contaSelecionada.corConta = Colors.black;
          }
          break;
        case 7:
          {
            _contaSelecionada.corConta = Colors.yellow;
          }
          break;
        case 8:
          {
            _contaSelecionada.corConta = Colors.white;
          }
          break;
        case 9:
          {
            _contaSelecionada.corConta = Colors.pink;
          }
          break;
        case 10:
          {
            _contaSelecionada.corConta = Colors.deepPurple;
          }
          break;
        case 11:
          {
            _contaSelecionada.corConta = Colors.blueGrey;
          }
          break;
        case 12:
          {
            _contaSelecionada.corConta = Colors.brown;
          }
          break;
      }
    });
  }
}
