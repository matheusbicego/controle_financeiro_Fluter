import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/telasCadastros/cadastroOrcamentos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class TelaOrcamento extends StatefulWidget {
  final Orcamento orcamento;

  TelaOrcamento({this.orcamento});

  @override
  _TelaOrcamentoState createState() => _TelaOrcamentoState();
}

class _TelaOrcamentoState extends State<TelaOrcamento> {

  NumberFormat formatter = NumberFormat("00.00");
  Orcamento _orcamentoAtual;
  DatabaseHelper helper = DatabaseHelper();
  List<Movimentacao> _movimentos = List();
  List<Movimentacao> _movimentosPData = List();
  List<Categoria> _categoria = List();
  List<Conta>  _contasMovimentacoes = List();

  int auxCor = 0;
  int i = 0;

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _chamaFuncoes();
  }

  void _chamaFuncoes() {
    _mapeaOrcamentoAtual();
    _listMovimentacoes();
    _getContas();
    _getCategoria();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65.0),
          child: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              _orcamentoAtual.descricaoOrcamento,
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
                            title: Text("Excluir Orcamento?"),
                            content:
                            Text("Deseja realmente excluir este orcamento?"),
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
                                  if (_movimentos.isEmpty) {
                                    helper.deleteOrcamento(_orcamentoAtual.idOrcamento);
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
                                                "Este orcamento possui movimentações relacionadas, portanto não poderá ser excluido. Para efetuar a exclusão sera nescessario excluir suas movimentações primeiro."),
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
                  _mostraEdicaoOrcamento(_orcamentoAtual);
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            _fazBody(),
          ],
        ));
  }

  Widget _fazBody() {
    return Column(
      children: <Widget>[
       Container(
         decoration: BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
         ),
          child: Center(
            child: Text(
              "Movimentações do Orcamento",
              style: TextStyle(fontSize: 25.0),
            ),
          ),
        ),
       Expanded(
          child: ListView.builder(
          itemCount: _movimentos.length,
          itemBuilder: (context, index) {
          return _criaListaTela(context, index);
    }),
    ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 3.0)),
          ),
          height: 200.0,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Categoria:",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Text(_categoria[0].nomeCategoria, style: TextStyle(fontSize: 20.0)),
                 Padding(padding: EdgeInsets.all(20.0),),
                 Column(
                    children: <Widget>[
                      Text("Data inicio",style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text(_orcamentoAtual.dataInicioOrcamento, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Gasto:",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Text(formatter.format(_orcamentoAtual.valorAtualOrcamento), style: TextStyle(fontSize: 20.0)),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 15.0),),
              Row(
                children: <Widget>[
                  Text("Total:",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Text(formatter.format(_orcamentoAtual.valorTotalOrcamento), style: TextStyle(fontSize: 20.0)),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 30.0),),
              Wrap(
                children: <Widget>[
                  Text("RENOVAÇÃO/VENCIMENTO",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                ],
              ),
              Wrap(
                children: <Widget>[
                  Text(_orcamentoAtual.dataFimOrcamento, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                ],
              ),
              Wrap(
                children: <Widget>[
                 Text("(A cada ${_orcamentoAtual.diasRenovacao} dias)"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _criaListaTela(BuildContext context, int index){
    _getCorMovimentacao(context, index);
    return Card(
      child: GestureDetector(
        child: Container(
          color: _contasMovimentacoes[auxCor].corConta,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                 Container(
                   child: Wrap(
                       children: <Widget>[
                         Text("Descrição: ${_movimentos[index].motivoMovimentacao}",style: TextStyle(fontSize: 20.0)),
                       ]),
                 ),
              Padding(padding: EdgeInsets.only(top: 7.0),),
              Container(
                child: Wrap(
                  children: <Widget>[
                    Text("Valor: ${_movimentos[index].valorMovimentacao}",style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 7.0),),
              Container(
                child: Wrap(
                  children: <Widget>[
                    Text("Data: ${_movimentos[index].dataHoraMovimentacao}",style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 7.0),),
              Container(
                child: Wrap(
                  children: <Widget>[
                    Text("Conta: ", style: TextStyle(fontSize: 20.0)),
                    _verificaConta(index),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
        },
      ),
    );
  }

  Future<void> _mostraEdicaoOrcamento(Orcamento orcamentos) async {
    final recOrcamento = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroOrcamento(
              orcamento: orcamentos,
            )));
    setState(() {
      helper.updateOrcamento(recOrcamento);
      _mapeaOrcamentoAtual();
    });
  }

  void _getCorMovimentacao(BuildContext context, int index) {
    auxCor = 0;
    while(_movimentos[index].idConta != _contasMovimentacoes[auxCor].idConta){
      auxCor++;
    }
    switch (_contasMovimentacoes[auxCor].idCorConta) {
      case 1:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.red;
        }
        break;
      case 2:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.blue;
        }
        break;
      case 3:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.indigo;
        }
        break;
      case 4:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.orange;
        }
        break;
      case 5:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.green;
        }
        break;
      case 6:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.pinkAccent;
        }
        break;
      case 7:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.yellow;
        }
        break;
      case 8:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.limeAccent;
        }
        break;
      case 9:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.pink;
        }
        break;
      case 10:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.deepPurple;
        }
        break;
      case 11:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.blueGrey;
        }
        break;
      case 12:
        {
          _contasMovimentacoes[auxCor].corConta = Colors.brown;
        }
        break;
    }
  }

  Widget _verificaConta(int index) {
    i = 0;
    while (_movimentos[index].idConta != _contasMovimentacoes[i].idConta) {
      i++;
    }
    return Text(_contasMovimentacoes[i].nomeConta, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  Future<void> _mapeaOrcamentoAtual() async {
    setState(() {
      _orcamentoAtual = Orcamento.fromMap(widget.orcamento.toMap());
    });
  }

  Future<void> _listMovimentacoes() async {
    int data = 0;
    _movimentos = [];
    await helper.getOrcamentoMovimentacao(_orcamentoAtual.idOrcamento).then((list) {
      setState(() {
        _movimentosPData = list;
        var dataIni = DateTime.parse(_orcamentoAtual.dataInicioOrcamento);
        var dataFim = DateTime.parse(_orcamentoAtual.dataFimOrcamento);
          do{
            var dataMov = DateTime.parse(_movimentosPData[data].dataHoraMovimentacao);
            if(dataMov.year >= dataIni.year && dataMov.year <= dataFim.year) {
              if ((dataMov.month >= dataIni.month ||
                  dataMov.year > dataIni.year) &&
                  (dataMov.month <= dataFim.month || dataMov.year < dataFim.year)) {
                if ((dataMov.day >= dataIni.day ||
                    dataMov.month > dataIni.month ||  dataMov.year > dataIni.year) &&
                    (dataMov.day <= dataFim.day || dataMov.month < dataFim.month || dataMov.year < dataFim.year)) {
                  _movimentos.add(_movimentosPData[data]);
                  print(_movimentos);
                }
              }
            }
            data++;
          }while(data < _movimentosPData.length);
      });
    });
  }

  Future<void> _getCategoria() async{
    await helper.getOrcamentoCategoriaUnic(_orcamentoAtual.idCategoria).then((list){
      setState(() {
        _categoria = list;
      });
    });
  }

  Future<void> _getContas() async{
    await helper.getMovimentacaoConta().then((list){
      setState(() {
        _contasMovimentacoes = list;
      });
    });
  }
}
