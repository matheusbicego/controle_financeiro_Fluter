import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaContas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class Transferencia extends StatefulWidget {
  @override
  _TransferenciaState createState() => _TransferenciaState();
}

class _TransferenciaState extends State<Transferencia> {

  Color aux1;
  Color aux2;

  DatabaseHelper helper = DatabaseHelper();

  List<Conta> _contas = List();
  List<DropdownMenuItem<Conta>> _dropdownMenuConta = List();
  Conta _selectedConta1;
  Conta _selectedConta2;
  final _contaMovimentacaoFocus1 = FocusNode();
  final _contaMovimentacaoFocus2 = FocusNode();
  static DateTime now = DateTime.now();
  static String formattedDate = DateFormat('dd/MM/yyyy - kk:mm').format(now);

  Movimentacao _novoMovimento1;
  Movimentacao _novoMovimento2;

  final _motivoMovimentacaoController = TextEditingController();
  final _motivoMovimentacaoFocus = FocusNode();
  final _valorMovimentacaoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _valorMovimentacaoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _getAllContas();
    _novoMovimento1 = Movimentacao();
    _novoMovimento2 = Movimentacao();
    aux1 = Colors.white;
    aux2 = Colors.white;
  }

  void onChangeDropdownItemConta1(Conta selectedConta) {
    setState(() {
      _selectedConta1 = selectedConta;
    });
  }

  void onChangeDropdownItemConta2(Conta selectedConta) {
    setState(() {
      _selectedConta2 = selectedConta;
    });
  }

  List<DropdownMenuItem<Conta>> buildDropdownMenuConta(List contas) {
    List<DropdownMenuItem<Conta>> items = List();
    for (Conta conta in contas) {
      items.add(
        DropdownMenuItem(
          value: conta,
          child: Text(conta.nomeConta),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(65.0),
            child: AppBar(
              title: Text(
                "Transferencia",
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
              backgroundColor: Colors.black,
              centerTitle: true,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                corpoTransferencia(),
                FlatButton(
                  child: Text(
                    "Transferir",
                    style: TextStyle(fontSize: 27.0),
                  ),
                  color: Colors.grey,
                  onPressed: () {
                    if(_novoMovimento1.idConta != null){
                      if(_novoMovimento2.idConta != null){
                        if(_novoMovimento1.motivoMovimentacao != null){
                          if(_novoMovimento2.motivoMovimentacao != null){
                            if(_novoMovimento1.valorMovimentacao != null){
                              if(_novoMovimento2.valorMovimentacao != null){
                                ajeitaMovimento();
                                mudaSaldoConta();
                                showDialog(barrierDismissible: false, context: context,
                                    builder: (context)
                                    {
                                      return AlertDialog (
                                        title: Text ("Transferencia Realizada"),
                                        content: Text (
                                            "Transferencia realizada com sucesso!"),
                                        actions: <Widget>[
                                          FlatButton (
                                            child: Text ("OK"),
                                            onPressed: () {
                                              _voltaTela();
                                            },
                                          ),
                                          FlatButton (
                                            child: Text ("Nova Transferencia"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => Transferencia(
                                                  )
                                              ));
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                );
                              }else{
                                FocusScope.of(context)
                                    .requestFocus(_valorMovimentacaoFocus);
                              }
                            }else{
                              FocusScope.of(context)
                                  .requestFocus(_valorMovimentacaoFocus);
                            }
                          }else{
                            FocusScope.of(context)
                                .requestFocus(_motivoMovimentacaoFocus);
                          }
                        }else{
                          FocusScope.of(context)
                              .requestFocus(_motivoMovimentacaoFocus);
                        }
                      }else{
                        FocusScope.of(context)
                            .requestFocus(_contaMovimentacaoFocus1);
                      }
                    }else{
                      FocusScope.of(context)
                          .requestFocus(_contaMovimentacaoFocus2);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget corpoTransferencia(){
    return Column(
      children: <Widget>[
        Text("Realizar transferencia", style: TextStyle(fontSize: 30.0),),
        Padding(
          padding: EdgeInsets.only(bottom: 30.0),
        ),
        Row(
          children: <Widget>[
            Text("De:",style: TextStyle(fontSize: 20.0),),
          ],
        ),
        decideConta1(),
        Padding(
          padding: EdgeInsets.only(bottom: 50.0),
        ),
        Row(
          children: <Widget>[
            Text("Para:",style: TextStyle(fontSize: 20.0),),
          ],
        ),
        decideConta2(),
        decideValor(),
      ],
    );
  }

  Widget decideConta1() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Conta saida:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
            ],
          ),
          DropdownButton(
            focusNode: _contaMovimentacaoFocus1,
            style: TextStyle(fontSize: 25.0, color: Colors.black),
            hint: Text("Selecione a conta"),
            value: _selectedConta1,
            items: _dropdownMenuConta,
            onChanged: (valor) {
              setState(() {
                onChangeDropdownItemConta1(valor);
               decideCorConta1(_selectedConta1.idCorConta);
                _novoMovimento1.idConta = _selectedConta1.idConta;
              });
            },
            isExpanded: true,
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0)),
          color: aux1),
    );
  }

  Widget decideConta2() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Conta entrada:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
            ],
          ),
          DropdownButton(
            focusNode: _contaMovimentacaoFocus2,
            style: TextStyle(fontSize: 25.0, color: Colors.black),
            hint: Text("Selecione a conta"),
            value: _selectedConta2,
            items: _dropdownMenuConta,
            onChanged: (valor) {
              setState(() {
                onChangeDropdownItemConta2(valor);
                 decideCorConta2(_selectedConta2.idCorConta);
                _novoMovimento2.idConta = _selectedConta2.idConta;
              });
            },
            isExpanded: true,
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0)),
          color: aux2),
    );
  }

  Widget decideValor() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0))),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _motivoMovimentacaoController,
            focusNode: _motivoMovimentacaoFocus,
            decoration: InputDecoration(labelText: "Descrição da transferencia "),
            onChanged: (text) {
              setState(() {
                _novoMovimento1.motivoMovimentacao = text;
                _novoMovimento2.motivoMovimentacao = text;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 25.0),
          ),
          TextField(
            controller: _valorMovimentacaoController,
            focusNode: _valorMovimentacaoFocus,
            decoration: InputDecoration(labelText: "Valor"),
            onChanged: (double) {
              setState(() {
                var aux = _valorMovimentacaoController.numberValue;
                if (aux == null) {
                  aux = 0.0;
                }
                _novoMovimento1.valorMovimentacao = aux * (-1);
                _novoMovimento2.valorMovimentacao = aux;
              });
            },
            keyboardType: TextInputType.number,
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 25.0),
    );
  }

  Future<Null> _requestPop() async{
    Navigator.pop(context);
    Navigator.pop(context);
    await Navigator.push(context, MaterialPageRoute(
        builder: (context) => MostraContas(
        )));
  }

  Future<Null> _voltaTela() async{
    Navigator.pop (context);
    Navigator.pop (context);
    Navigator.pop (context);
    await Navigator.push(context, MaterialPageRoute(
        builder: (context) => MostraContas(
        )));
  }

  void decideCorConta1(int idCorConta) {
    switch (idCorConta) {
      case 1:
        {
          aux1 = Colors.red;
        }
        break;
      case 2:
        {
          aux1 = Colors.blue;
        }
        break;
      case 3:
        {
          aux1 = Colors.indigo;
        }
        break;
      case 4:
        {
          aux1 = Colors.orange;
        }
        break;
      case 5:
        {
          aux1 = Colors.green;
        }
        break;
      case 6:
        {
          aux1 = Colors.pinkAccent;
        }
        break;
      case 7:
        {
          aux1 = Colors.yellow;
        }
        break;
      case 8:
        {
          aux1 = Colors.limeAccent;
        }
        break;
      case 9:
        {
          aux1 = Colors.pink;
        }
        break;
      case 10:
        {
          aux1 = Colors.deepPurple;
        }
        break;
      case 11:
        {
          aux1 = Colors.blueGrey;
        }
        break;
      case 12:
        {
          aux1 = Colors.brown;
        }
        break;
    }
  }

  void decideCorConta2(int idCorConta) {
    switch (idCorConta) {
      case 1:
        {
          aux2 = Colors.red;
        }
        break;
      case 2:
        {
          aux2 = Colors.blue;
        }
        break;
      case 3:
        {
          aux2 = Colors.indigo;
        }
        break;
      case 4:
        {
          aux2 = Colors.orange;
        }
        break;
      case 5:
        {
          aux2 = Colors.green;
        }
        break;
      case 6:
        {
          aux2 = Colors.black;
        }
        break;
      case 7:
        {
          aux2 = Colors.yellow;
        }
        break;
      case 8:
        {
          aux2 = Colors.white;
        }
        break;
      case 9:
        {
          aux2 = Colors.pink;
        }
        break;
      case 10:
        {
          aux2 = Colors.deepPurple;
        }
        break;
      case 11:
        {
          aux2 = Colors.blueGrey;
        }
        break;
      case 12:
        {
          aux2 = Colors.brown;
        }
        break;
    }
  }

  Future<void> ajeitaMovimento() async{
    _novoMovimento1.idCategoria = 1;
    _novoMovimento1.naturezaOperacaoMovimentacao = "Transferencia";
    _novoMovimento1.tipoMovimentacao = "Saida";
    _novoMovimento1.dataHoraMovimentacao = formattedDate;

    _novoMovimento2.idCategoria = 3;
    _novoMovimento2.naturezaOperacaoMovimentacao = "Transferencia";
    _novoMovimento2.tipoMovimentacao = "Entrada";
    _novoMovimento2.dataHoraMovimentacao = formattedDate;

    await helper.saveMovimentacao(_novoMovimento1);
    await helper.saveMovimentacao(_novoMovimento2);

    _novoMovimento1.idTransferencia = _novoMovimento2.idMovimentacao;
    _novoMovimento2.idTransferencia = _novoMovimento1.idMovimentacao;

    await helper.updateMovimentacao(_novoMovimento1);
    await helper.updateMovimentacao(_novoMovimento2);
  }

  void mudaSaldoConta(){
    setState(() {
      _selectedConta1.saldoConta += _novoMovimento1.valorMovimentacao;
      _selectedConta2.saldoConta += _novoMovimento2.valorMovimentacao;
      helper.updateConta(_selectedConta1);
      helper.updateConta(_selectedConta2);
    });
  }

  Future<void> _getAllContas() async {
    helper.getAllConta().then((list) {
      setState(() {
        _contas = list;
        _dropdownMenuConta = buildDropdownMenuConta(_contas);
      });
    });
  }
}
