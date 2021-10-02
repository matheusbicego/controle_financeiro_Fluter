import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/telaConta.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class CadastroMovimentacao extends StatefulWidget {
  @override
  _CadastroMovimentacaoState createState() => _CadastroMovimentacaoState();

  Movimentacao movimentacao;

  CadastroMovimentacao({this.movimentacao});
}

class _CadastroMovimentacaoState extends State<CadastroMovimentacao> {
  DatabaseHelper helper = DatabaseHelper();

  List<Conta> _contas = List();
  List<DropdownMenuItem<Conta>> _dropdownMenuConta = List();
  Conta _selectedConta;
  final _contaMovimentacaoFocus = FocusNode();
  DateTime selectedDate = DateTime.now();
  DateTime now = DateTime.now();

  List<Categoria> _categorias = List();
  List<DropdownMenuItem<Categoria>> _dropdownMenuCategoria = List();
  Categoria _selectedCategoria;

  List<Orcamento> _orcamentos = List();
  List<DropdownMenuItem<Orcamento>> _dropdownMenuOrcamento = List();
  Orcamento _selectedOrcamento;

  List<CartaoCredito> _cartoesCredito = List();
  List<DropdownMenuItem<CartaoCredito>> _dropdownMenuCartaoCredito = List();
  CartaoCredito _selectedCartaoCredito;

  int _radioValueTipo = 0;
  int _radioValueNatureza = 2;
  final _motivoMovimentacaoController = TextEditingController();
  final _valorMovimentacaoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _motivoMovimentacaoFocus = FocusNode();
  final _valorMovimentacaoFocus = FocusNode();
  final _cartaoCreditoFocus = FocusNode();

  Movimentacao _novoMovimento;

  bool flagConta = false;
  bool flagCat = false;

  @override
  void initState() {
    super.initState();
    flagConta = false;
    flagCat = false;
    _getAllContas();
    _getAllCategorias();
    aux = Colors.white;
    _novoMovimento = Movimentacao();
    _novoMovimento.naturezaOperacaoMovimentacao = "Débito";
    _novoMovimento.tipoMovimentacao = "Entrada";
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

  List<DropdownMenuItem<Categoria>> buildDropdownMenuCategorias(
      List categorias) {
    List<DropdownMenuItem<Categoria>> items = List();
    for (Categoria categoria in categorias) {
      items.add(
        DropdownMenuItem(
          value: categoria,
          child: Text(categoria.nomeCategoria),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Orcamento>> buildDropdownMenuOrcamentos(
      List orcamentos) {
    List<DropdownMenuItem<Orcamento>> items = List();
    for (Orcamento orcamento in orcamentos) {
      items.add(
        DropdownMenuItem(
          value: orcamento,
          child: Text(orcamento.descricaoOrcamento),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<CartaoCredito>> buildDropdownMenuCartaoCredito(
      List cartoesCredito) {
    List<DropdownMenuItem<CartaoCredito>> items = List();
    for (CartaoCredito cartaoCredito in cartoesCredito) {
      items.add(
        DropdownMenuItem(
          value: cartaoCredito,
          child: Text(cartaoCredito.nomeCartaoCredito),
        ),
      );
    }
    return items;
  }

  void onChangeDropdownItemConta(Conta selectedConta) {
    setState(() {
      _selectedConta = selectedConta;
    });
  }

  void onChangeDropdownItemCategoria(Categoria selectedCategoria) {
    setState(() {
      _selectedCategoria = selectedCategoria;
    });
  }

  void onChangeDropdownItemOrcamento(Orcamento selectedOrcamento) {
    setState(() {
      _selectedOrcamento = selectedOrcamento;
    });
  }

  void onChangeDropdownItemCartaoCredito(CartaoCredito selectedCartaoCredito) {
    setState(() {
      _selectedCartaoCredito = selectedCartaoCredito;
    });
  }

  void _mudarValorRadio(int value) {
    setState(() {
      switch (value) {
        case 0:
          {
            _novoMovimento.tipoMovimentacao = "Entrada";
            _radioValueTipo = 0;
            break;
          }
        case 1:
          {
            _novoMovimento.tipoMovimentacao = "Saida";
            _radioValueTipo = 1;
            break;
          }
      }
      switch (value) {
        case 2:
          {
            _novoMovimento.naturezaOperacaoMovimentacao = "Débito";
            _radioValueNatureza = 2;
            break;
          }
        case 3:
          {
            _novoMovimento.naturezaOperacaoMovimentacao = "Crédito";
            _radioValueNatureza = 3;
            break;
          }
      }
    });
  }

  void _mudaTipoRadioEntrada(int value){
    if(value == 0){
      _novoMovimento.naturezaOperacaoMovimentacao = "Débito";
      _radioValueNatureza = 2;
    }
  }

  void _mudaTipoRadioCredito(int value){
    if(value == 3){
      _novoMovimento.tipoMovimentacao = "Saida";
      _radioValueTipo = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          title: Text(
            "Casdastrar Movimentação",
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            fazTela(),
          ],
        ),
      ),
    );
  }

  Widget fazTela(){
    if(flagCat == false || flagConta == false){
      Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 300.0),),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }else{
      return Column(
        children: <Widget>[
          corpoCadastroMovimentacao(),
          FlatButton(
            child: Text(
              "Salvar",
              style: TextStyle(fontSize: 27.0),
            ),
            color: Colors.grey,
            onPressed: () {
              if (_novoMovimento.idConta != null) {
                if (_novoMovimento.motivoMovimentacao != null &&
                    _novoMovimento.motivoMovimentacao.isNotEmpty) {
                  if (_novoMovimento.valorMovimentacao != null){
                    ajeitaValor ();
                    if((_novoMovimento.naturezaOperacaoMovimentacao != "Crédito") && (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day)){
                      _selectedConta.saldoConta += _novoMovimento.valorMovimentacao;
                      _novoMovimento.somadaConta = true;
                    }
                    if(_novoMovimento.naturezaOperacaoMovimentacao == "Crédito"){
                      _novoMovimento.somadaConta = true;
                    }
                    helper.updateConta (_selectedConta);
                    if ((_selectedOrcamento != null) && (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day)) {
                      mudaSaldoOrcamento ();
                    }
                    if(_selectedOrcamento != null){
                      _novoMovimento.idOrcamento = _selectedOrcamento.idOrcamento;
                      _novoMovimento.somadaOrcamento = true;
                    }
                    if(selectedDate.day != now.day){
                      String formattedDate = DateFormat('yyyy-MM-dd 00:00:00').format(selectedDate);
                      _novoMovimento.dataHoraMovimentacao = formattedDate;
                    }else{
                      String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(selectedDate);
                      _novoMovimento.dataHoraMovimentacao = formattedDate;
                    }
                    if(_novoMovimento.naturezaOperacaoMovimentacao == "Crédito" && _selectedCartaoCredito.idCartaoCredito != null){
                      _novoMovimento.idCartaoCredito = _selectedCartaoCredito.idCartaoCredito;
                    }
                    if(_novoMovimento.naturezaOperacaoMovimentacao == "Crédito" && _selectedCartaoCredito.idCartaoCredito != null){
                      ajeitaValor();
                      Navigator.pop(context, _novoMovimento);
                    }else{
                      if(_novoMovimento.naturezaOperacaoMovimentacao == "Débito"){
                        if(_selectedConta.saldoConta < (_selectedConta.limiteChequeEspecialConta *(-1))) {
                          setState(() {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Aviso"),
                                    content:
                                    Text("Voce esta ultrapassando o limite cheque especial tome cuidado!"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context, _novoMovimento);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          });
                        }else{
                          Navigator.pop(context, _novoMovimento);
                        }
                      }else{
                        FocusScope.of(context)
                            .requestFocus(_cartaoCreditoFocus);
                      }
                    }

                  } else
                    FocusScope.of(context)
                        .requestFocus(_valorMovimentacaoFocus);
                } else {
                  FocusScope.of(context).requestFocus(_motivoMovimentacaoFocus);
                }
              } else {
                FocusScope.of(context).requestFocus(_contaMovimentacaoFocus);
              }
            },
          ),
        ],
      );
    }
  }

  Widget corpoCadastroMovimentacao() {
    return Column(
        children: <Widget>[
          decideConta(),
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
          ),
          decideCategoria(),
          decideValor(),
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
          ),
          decideData(),
          Padding(
            padding: EdgeInsets.only(bottom: 35.0),
          ),
        ],
      );
  }

  Widget decideConta() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Conta:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
            ],
          ),
          DropdownButton(
            focusNode: _contaMovimentacaoFocus,
            style: TextStyle(fontSize: 25.0, color: Colors.black),
            hint: Text("Selecione a conta"),
            value: _selectedConta,
            items: _dropdownMenuConta,
            onChanged: (valor) {
              setState(() {
                onChangeDropdownItemConta(valor);
                decideCorConta(_selectedConta.idCorConta);
                _novoMovimento.idConta = _selectedConta.idConta;
                _pegaCartaoCredito();
                _selectedCartaoCredito = null;
              });
            },
            isExpanded: true,
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0)),
          color: aux),
    );
  }

  Widget decideCategoria() {
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0))),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Categoria:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
              ],
            ),
            DropdownButton(
              hint: Text("Selecione a categoria"),
              value: _selectedCategoria,
              items: _dropdownMenuCategoria,
              onChanged: (valor) {
                setState(() {
                  onChangeDropdownItemCategoria(valor);
                  _orcamentos.isEmpty;
                  _dropdownMenuOrcamento = null;
                  _selectedOrcamento = null;
                  pegaOrcamentos(_selectedCategoria.idCategoria);
                  _novoMovimento.idCategoria = _selectedCategoria.idCategoria;
                });
              },
              isExpanded: true,
            ),
            decideOrcamento(),
          ],
        ));
  }

  Widget decideOrcamento() {
    if (_orcamentos.isEmpty) {
      pegaOrcamentos(_selectedCategoria.idCategoria);
    }
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "Orcamento:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            ),
          ],
        ),
        DropdownButton(
          disabledHint: Text("Sem orçamento cadastrado para esta categoria"),
          hint: Text("Selecione o orçamento"),
          value: _selectedOrcamento,
          items: _dropdownMenuOrcamento,
          onChanged: (valor) {
            setState(() {
              onChangeDropdownItemOrcamento(valor);
            });
          },
          isExpanded: true,
        ),
      ],
    );
  }

  Widget decideValor() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0))),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Radio(
                value: 0,
                groupValue: _radioValueTipo,
                onChanged: (value){
                  _mudarValorRadio(value);
                  _mudaTipoRadioEntrada(value);
                },
              ),
              Text("Entrada"),
              Padding(
                padding: EdgeInsets.only(left: 80.0),
              ),
              Radio(
                value: 1,
                groupValue: _radioValueTipo,
                onChanged: _mudarValorRadio,
              ),
              Text("Saida"),
            ],
          ),
          TextField(
            controller: _motivoMovimentacaoController,
            focusNode: _motivoMovimentacaoFocus,
            decoration: InputDecoration(labelText: "Descrição do movimento "),
            onChanged: (text) {
              setState(() {
                _novoMovimento.motivoMovimentacao = text;
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
                _novoMovimento.valorMovimentacao = aux;
              });
            },
            keyboardType: TextInputType.number,
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          Row(
            children: <Widget>[
              Radio(
                value: 2,
                groupValue: _radioValueNatureza,
                onChanged: _mudarValorRadio,
              ),
              Text("Débito"),
              Padding(
                padding: EdgeInsets.only(left: 80.0),
              ),
              Radio(
                value: 3,
                groupValue: _radioValueNatureza,
                onChanged: (value){
                  _mudarValorRadio(value);
                  _mudaTipoRadioCredito(value);
                }
              ),
              Text("Crédito"),
            ],
          ),
          _decideCartaoCredito(),
        ],
      ),
      padding: EdgeInsets.only(bottom: 25.0),
    );
  }

  Widget _decideCartaoCredito(){
    if(_novoMovimento.naturezaOperacaoMovimentacao == "Crédito"){
      return Column(
        children: <Widget>[
          DropdownButton(
            disabledHint: Text("Sem cartão cadastrado para esta conta"),
            hint: Text("Selecione o cartão de credito"),
            value: _selectedCartaoCredito,
            items: _dropdownMenuCartaoCredito,
            focusNode: _cartaoCreditoFocus,
            onChanged: (valor) {
              setState(() {
                onChangeDropdownItemCartaoCredito(valor);
              });
            },
            isExpanded: true,
          ),
        ],
      );
    }else{
      return Container();
    }
  }

  Widget decideData(){
    return Row(
      children: <Widget>[
        Text("Data da movimentação: ", style: TextStyle(fontSize: 18.0),),
        RaisedButton(
          onPressed: (){
            _selectDate(context);
          },
          child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}".split(' ')[0]),
        ),
      ],
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    var dataFim = selectedDate.add(new Duration(days: 9999999));
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(dataFim.year));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  Future<void> pegaOrcamentos(int id) async {
    await helper.getCategoriaOrcamento(id).then((list) {
      setState(() {
        _orcamentos = list;
        _dropdownMenuOrcamento = buildDropdownMenuOrcamentos(_orcamentos);
      });
    });
  }

  Future<void> _pegaCartaoCredito() async {
    await helper.getContaCartaoCredito(_selectedConta.idConta).then((list) {
      setState(() {
        _cartoesCredito = list;
        _dropdownMenuCartaoCredito = buildDropdownMenuCartaoCredito(_cartoesCredito);
      });
    });
  }

  Future<void> _getAllContas() async {
    await helper.getAllConta().then((list) {
      setState(() {
        _contas = list;
        _dropdownMenuConta = buildDropdownMenuConta(_contas);
      });
    });
    flagConta = true;
  }

  Future<void> _getAllCategorias() async {
   await helper.getAllCategoria().then((list) {
      setState(() {
        _categorias = list;
        _dropdownMenuCategoria = buildDropdownMenuCategorias(_categorias);
        _selectedCategoria = _dropdownMenuCategoria[0].value;
        _novoMovimento.idCategoria = _selectedCategoria.idCategoria;
      });
    });
   flagCat = true;
  }
  void decideCorConta(int idCorConta) {
    switch (idCorConta) {
      case 1:
        {
          aux = Colors.red;
        }
        break;
      case 2:
        {
          aux = Colors.blue;
        }
        break;
      case 3:
        {
          aux = Colors.indigo;
        }
        break;
      case 4:
        {
          aux = Colors.orange;
        }
        break;
      case 5:
        {
          aux = Colors.green;
        }
        break;
      case 6:
        {
          aux = Colors.pinkAccent;
        }
        break;
      case 7:
        {
          aux = Colors.yellow;
        }
        break;
      case 8:
        {
          aux = Colors.limeAccent;
        }
        break;
      case 9:
        {
          aux = Colors.pink;
        }
        break;
      case 10:
        {
          aux = Colors.deepPurple;
        }
        break;
      case 11:
        {
          aux = Colors.blueGrey;
        }
        break;
      case 12:
        {
          aux = Colors.brown;
        }
        break;
    }
  }

  void ajeitaValor(){
    if(_novoMovimento.tipoMovimentacao == "Saida"){
      _novoMovimento.valorMovimentacao *= (-1);
    }
  }

  void mudaSaldoOrcamento(){
    double auxVar;
    auxVar =  _novoMovimento.valorMovimentacao;
    if(_novoMovimento.idCategoria == 3){
      _selectedOrcamento.valorAtualOrcamento += auxVar;
    }else {
      auxVar = auxVar * (-1);
      _selectedOrcamento.valorAtualOrcamento += auxVar;
    }
    setState(() {
      helper.updateOrcamento(_selectedOrcamento);
    });
  }
}
