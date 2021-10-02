import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/telaMovimentosCartaoCredito.dart';
import 'package:controle_de_financas/telasCadastros/cadastroCartaoCredito.dart';
import 'package:controle_de_financas/telasCadastros/cadastroContas.dart';
import 'package:flutter/material.dart';
import 'package:controle_de_financas/detalhes/detalheQuadratcBazier.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Color aux;

class TelaConta extends StatefulWidget {
  final Conta conta;

  TelaConta({this.conta});

  @override
  _TelaContaState createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  NumberFormat formatter = NumberFormat("00.00");
  Conta _contaAtual;
  BezierApp quadraticBazier = BezierApp();
  DatabaseHelper helper = DatabaseHelper();
  List<Movimentacao> _movimentos = List();
  List<Movimentacao> _movimentosMes = List();
  List<Movimentacao> _movimentacao = List();
  List<Conta> _nomeConta = List();
  List<CartaoCredito> _cartaoCredito = List();
  List<Categoria> _nomeCategoria = List();
  List<Orcamento> _orcamento = List();
  static DateTime now = DateTime.now();
  DateTime atualizaMes = now.subtract(new Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(65.0),
              child: AppBar(
                backgroundColor: _contaAtual.corConta,
                title: Text(
                  _contaAtual.nomeConta,
                  style: TextStyle(fontSize: 25.0, color: Colors.white),
                ),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Excluir Conta?"),
                                content:
                                Text("Deseja realmente excluir esta conta?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Cancelar"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Excluir"),
                                    onPressed: () {
                                      if (_movimentos.isEmpty && _cartaoCredito.isEmpty) {
                                        helper.deleteConta(_contaAtual.idConta);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Erro"),
                                                content: Text(
                                                    "Esta conta possui movimentações ou cartões relacionados, portanto não poderá ser excluida. Para efetuar a exclusão sera nescessario excluir suas movimentações primeiro."),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      }
                                    },
                                  ),
                                ],
                              );
                            });
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _mostraEdicaoContas(_contaAtual);
                    },
                  ),
                ],
              ),
            ),
            body: Stack(
              children: <Widget>[
                quadraticBazier,
                _fazBody(),
              ],
            )),
    );

  }

  Widget _fazBody() {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 2.0))),
              child: Stack(
                children: <Widget>[
                  Center(
                      child: Padding(
                    padding: EdgeInsets.only(bottom: 60.0),
                    child: Text(
                      "Saldo",
                      style: TextStyle(fontSize: 50.0),
                    ),
                  )),
                  FlatButton.icon(
                      onPressed:(){
                        _mostraCadastroCartaoCredito(_contaAtual);
                      } ,
                      icon: Icon(Icons.add_box),
                      label: Text("Add Cartão de credito"),
                  ),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 120.0),
                    child: Text(
                      formatter.format(_contaAtual.saldoConta),
                      style: TextStyle(fontSize: 40.0),
                    ),
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height *0.25,
            ),
            Container(
              height: MediaQuery.of(context).size.height *0.35,
              decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 2.0))),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text("Movimentações dos ultimos 30 dias"),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: _movimentos.length,
                        itemBuilder: (context, index) {
                          return _criaListaMovimento(context, index);
                        }),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height *0.269,
              decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 2.0))),
              child:Column(
                    children: <Widget>[
                         Row(
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Text("Cartões de credito vinculados"),
                              ),
                            )
                          ],
                        ),
                        Container(
                          child: Expanded(
                            child: ListView.builder(
                                itemCount: _cartaoCredito.length,
                                itemBuilder: (context, index) {
                                  return _criaListaCartaoCredito(context, index);
                                }),
                          ),
                        ),
                    ],
                  ),
            ),
          ],
        ),
    );
  }

  _criaListaMovimento(BuildContext context, int index) {
    return GestureDetector(
      onTap: (){
        _mostraInformacoesMovimentacao(index);
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              _movimentos[index].motivoMovimentacao,
              style: TextStyle(fontSize: 18.0),
            ),
            Row(
              children: <Widget>[
                Text(
                  "Valor(R\$): ",
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  formatter.format(_movimentos[index].valorMovimentacao),
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _criaListaCartaoCredito(BuildContext context, int index) {
    return GestureDetector(
      onTap: (){
        _mostraDadosCartaoCredito(context, index);
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              _cartaoCredito[index].nomeCartaoCredito,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _mostraInformacoesMovimentacao(int index) async{
    setState(() {
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Informações"),
              content: Container(
                height: 350.0,
                child: Column(
                  children: <Widget>[
                    Wrap(
                      children: <Widget>[
                        Text("Nome: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_movimentos[index].motivoMovimentacao),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Valor: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(formatter.format(_movimentos[index].valorMovimentacao)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Data: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_movimentos[index].dataHoraMovimentacao),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Tipo: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_movimentos[index].tipoMovimentacao),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Operação: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_movimentos[index].naturezaOperacaoMovimentacao),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Categoria: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        nomeDaCategoria(index),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Orcamemto: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        nomeDoOrcamento(index),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text(_contaAtual.nomeConta, style: TextStyle(fontSize: 30.0),),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("Excluir"),
                      onPressed: (){
                        _excluiMovimento(index);
                      },
                    ),
                    Padding(padding: EdgeInsets.only(right: 150.0),),
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: (){
                        Navigator.pop(context);
                        _listMovimentacoes();
                        _decideCor();
                        _getAllCartaoCredito();
                        _getMovimentacaoCategoria();
                        _getOrcamentos();
                        _getAllMovimentacao();
                        _getMovimentacaoConta();
                      },
                    ),
                  ],
                ),
              ],
            );
          }
      );
    });
}

  Future<Null> _mostraDadosCartaoCredito(BuildContext context, int index) async{
    setState(() {
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Informações do Cartão"),
              content: Container(
                height: 350.0,
                child: Column(
                  children: <Widget>[
                    Wrap(
                      children: <Widget>[
                        Text("Nome: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_cartaoCredito[index].nomeCartaoCredito),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text("Data de cadastro: ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(_cartaoCredito[index].dataInicioCartaoCredito),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Wrap(
                      children: <Widget>[
                        Text(_contaAtual.nomeConta, style: TextStyle(fontSize: 30.0),),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(40.0),),
                    RaisedButton(
                      child: Text("Ver movimentações", style: TextStyle(fontSize: 20.0),),
                      onPressed: (){
                        _abreTelaMovimentacoesCartaoCredito(_cartaoCredito[index]);
                      },
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("Excluir"),
                      onPressed: (){
                        Navigator.pop(context);
                        _excluiCartaoCredito(index);
                      },
                    ),
                    FlatButton(
                      child: Text("Editar"),
                      onPressed: (){
                        Navigator.pop(context);
                        _mostraCadastroCartaoCredito(_contaAtual, cartaoCredito: _cartaoCredito[index]);
                      },
                    ),
                    Padding(padding: EdgeInsets.only(right: 104.0),),
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: (){
                        Navigator.pop(context);
                        _listMovimentacoes();
                        _decideCor();
                        _getAllCartaoCredito();
                        _getMovimentacaoCategoria();
                        _getOrcamentos();
                        _getAllMovimentacao();
                        _getMovimentacaoConta();
                      },
                    ),
                  ],
                ),
              ],
            );
          }
      );
    });
  }

  Future<void> _mostraEdicaoContas(Conta contas) async {
    final recConta = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroConta(
                  conta: contas,
                )));
    setState(() {
      helper.updateConta(recConta);
      _mapeaContaAtual();
      _decideCor();
    });
  }

  Widget nomeDaCategoria(int index){
    int o = 0;
    while(_movimentos[index].idCategoria != _nomeCategoria[o].idCategoria){
      o++;
    }
    return Text(_nomeCategoria[o].nomeCategoria);
  }

  Widget nomeDoOrcamento(int index){
    int n = 0;
    if(_movimentos[index].idOrcamento != null){
      while(_movimentos[index].idOrcamento != _orcamento[n].idOrcamento){
        n++;
      }
      return Text(_orcamento[n].descricaoOrcamento);
    }else{
      return Text("-");
    }
  }

  void _excluiMovimento(int index){
    setState(() {
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Excluir movimentação?"),
              content: Text("Deseja realmente excluir esta movimentação?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Não"),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: (){
                    if(_movimentos[index].naturezaOperacaoMovimentacao == "Transferencia"){
                      int t = 0;
                      int c2 = 0;
                      while(_movimentos[index].idMovimentacao != _movimentacao[t].idTransferencia){
                        t++;
                      }

                      while(_movimentacao[t].idConta != _nomeConta[c2].idConta){
                        c2++;
                      }
                      _contaAtual.saldoConta -= _movimentos[index].valorMovimentacao;
                      _nomeConta[c2].saldoConta -= _movimentacao[t].valorMovimentacao;
                      helper.deleteMovimentacao(_movimentos[index].idMovimentacao);
                      helper.deleteMovimentacao(_movimentacao[t].idMovimentacao);
                      helper.updateConta(_contaAtual);
                      helper.updateConta(_nomeConta[c2]);
                    }else{
                      if(_movimentos[index].naturezaOperacaoMovimentacao == "Crédito"){
                        if(_movimentos[index].idOrcamento != null){
                          int o = 0;
                          while(_movimentos[index].idOrcamento != _orcamento[o].idOrcamento){
                            o++;
                          }
                          _orcamento[o].valorAtualOrcamento -= _movimentos[index].valorMovimentacao;
                          helper.updateOrcamento(_orcamento[o]);
                        }
                        setState(() {
                          helper.deleteMovimentacao(_movimentos[index].idMovimentacao);
                        });
                      }else{
                        if(_movimentos[index].idOrcamento != null){
                          int o = 0;
                          while(_movimentos[index].idOrcamento != _orcamento[o].idOrcamento){
                            o++;
                          }
                          _orcamento[o].valorAtualOrcamento += _movimentos[index].valorMovimentacao;
                          helper.updateOrcamento(_orcamento[o]);
                        }
                        setState(() {
                          _contaAtual.saldoConta -= _movimentos[index].valorMovimentacao;
                          helper.updateConta(_contaAtual);
                          helper.deleteMovimentacao(_movimentos[index].idMovimentacao);
                        });
                      }
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() {
                      _reMapeaContaAtual();
                      _listMovimentacoes();
                      _decideCor();
                      _getAllCartaoCredito();
                      _getMovimentacaoCategoria();
                      _getOrcamentos();
                      _getAllMovimentacao();
                      _getMovimentacaoConta();
                    });
                  },
                ),
              ],
            );
          }
      );
    });
  }

  void _excluiCartaoCredito(int index){
    setState(() {
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Excluir cartão de credito?"),
              content: Text("Deseja realmente excluir este cartão?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Não"),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: (){
                    var flag = false;
                    for(int m = 0; m < _movimentos.length; m++){
                      if(_movimentos[m].idCartaoCredito == _cartaoCredito[index].idCartaoCredito){
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Erro"),
                                content: Text(
                                    "Este cartão possui movimentações relacionadas, portanto não poderá ser excluido. Para efetuar a exclusão sera nescessario excluir suas movimentações primeiro."),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Ok"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _reMapeaContaAtual();
                                        _listMovimentacoes();
                                        _getAllCartaoCredito();
                                        _getAllMovimentacao();
                                        _getMovimentacaoConta();
                                      });
                                    },
                                  ),
                                ],
                              );
                            });
                        flag = true;
                        break;
                      }
                    }
                    if(flag == false){
                      setState(() {
                        helper.deleteCartaoCredito(_cartaoCredito[index].idCartaoCredito);
                        Navigator.pop(context);
                      });
                      setState(() {
                        _reMapeaContaAtual();
                        _listMovimentacoes();
                        _getAllCartaoCredito();
                        _getAllMovimentacao();
                        _getMovimentacaoConta();
                      });
                    }
                  },
                ),
              ],
            );
          }
      );
    });
  }

  Future<Null> _requestPop() async{
    Navigator.pop(context, _contaAtual);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _chamaFuncoes();
  }

  void _chamaFuncoes() {
    _mapeaContaAtual();
    _listMovimentacoes();
    _decideCor();
    _getAllCartaoCredito();
    _getMovimentacaoCategoria();
    _getOrcamentos();
    _getAllMovimentacao();
    _getMovimentacaoConta();
  }

  void _mostraCadastroCartaoCredito(Conta conta, {CartaoCredito cartaoCredito}) async {
    final recCartaoCredito = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroCartaoCredito(
              conta: conta, cartaoCredito: cartaoCredito,
            )));
    if (recCartaoCredito != null) {
      if(cartaoCredito != null){
        helper.updateCartaoCredito(recCartaoCredito);
        _getAllCartaoCredito();
      }else{
        await helper.saveCartaoCredito((recCartaoCredito));
        _getAllCartaoCredito();
      }
    }
  }

  void _abreTelaMovimentacoesCartaoCredito(CartaoCredito cartaoCredito) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TelaMovimentosCartaoCredito(
              cartaoCredito: cartaoCredito,
            )));
  }

  void _decideCor() {
    setState(() {
      switch (_contaAtual.idCorConta) {
        case 1:
          {
            _contaAtual.corConta = Colors.red;
            aux = Colors.red;
          }
          break;
        case 2:
          {
            _contaAtual.corConta = Colors.blue;
            aux = Colors.blue;
          }
          break;
        case 3:
          {
            _contaAtual.corConta = Colors.indigo;
            aux = Colors.indigo;
          }
          break;
        case 4:
          {
            _contaAtual.corConta = Colors.orange;
            aux = Colors.orange;
          }
          break;
        case 5:
          {
            _contaAtual.corConta = Colors.green;
            aux = Colors.green;
          }
          break;
        case 6:
          {
            _contaAtual.corConta = Colors.pinkAccent;
            aux = Colors.pinkAccent;
          }
          break;
        case 7:
          {
            _contaAtual.corConta = Colors.yellow;
            aux = Colors.yellow;
          }
          break;
        case 8:
          {
            _contaAtual.corConta = Colors.limeAccent;
            aux = Colors.limeAccent;
          }
          break;
        case 9:
          {
            _contaAtual.corConta = Colors.pink;
            aux = Colors.pink;
          }
          break;
        case 10:
          {
            _contaAtual.corConta = Colors.deepPurple;
            aux = Colors.deepPurple;
          }
          break;
        case 11:
          {
            _contaAtual.corConta = Colors.blueGrey;
            aux = Colors.blueGrey;
          }
          break;
        case 12:
          {
            _contaAtual.corConta = Colors.brown;
            aux = Colors.brown;
          }
          break;
      }
    });
  }

  Future<void> _mapeaContaAtual() async {
    setState(() {
      _contaAtual = Conta.fromMap(widget.conta.toMap());
    });
  }

  Future<void> _reMapeaContaAtual() async {
    setState(() {
      _contaAtual = _contaAtual;
    });
  }

  Future<void> _listMovimentacoes() async {
    int aux = 0;
    _movimentos = [];
    await helper.getContaMovimentacao(_contaAtual.idConta).then((list) {
      setState(() {
        _movimentosMes = list;
        do{
          var dataMov = DateTime.parse(_movimentosMes[aux].dataHoraMovimentacao);
          if(dataMov.year >= atualizaMes.year && dataMov.year <= now.year) {
            if ((dataMov.month >= atualizaMes.month ||
                dataMov.year > atualizaMes.year) &&
                (dataMov.month <= now.month || dataMov.year < now.year)) {
              if ((dataMov.day >= atualizaMes.day ||
                  dataMov.month > atualizaMes.month ||  dataMov.year > atualizaMes.year) &&
                  (dataMov.day <= now.day || dataMov.month < now.month || dataMov.year < now.year)) {
                  _movimentos.add(_movimentosMes[aux]);
              }
            }
          }
          aux++;
        }while(aux < _movimentosMes.length);
      });
    });
  }

  Future<void> _getAllMovimentacao() async {
     await helper.getAllMovimentacao().then((list) {
      setState(() {
        _movimentacao = list;
      });
    });
  }

  Future<void> _getAllCartaoCredito() async {
    await helper.getContaCartaoCredito(_contaAtual.idConta).then((list) {
      setState(() {
        _cartaoCredito = list;
      });
    });
  }

  Future<void> _getMovimentacaoConta() async {
    await helper.getMovimentacaoConta().then((list) {
      setState(() {
        _nomeConta = list;
      });
    });
  }

  Future<void> _getMovimentacaoCategoria() async {
    await helper.getCategoriaMovimento().then((list) {
      setState(() {
        _nomeCategoria = list;
      });
    });
  }

  Future<void> _getOrcamentos() async {
    await helper.getAllCategoriaOrcamento().then((list) {
      setState(() {
        _orcamento = list;
      });
    });
  }
}
