import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/banco/crudUsuario.dart';
import 'package:controle_de_financas/detalhes/menu.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/telaConta.dart';
import 'package:controle_de_financas/telasCadastros/cadastroContas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MostraContas extends StatefulWidget {
  @override
  _MostraContasState createState() => _MostraContasState();
}

class _MostraContasState extends State<MostraContas> {

  NumberFormat formatter = NumberFormat ("00.00");
  DateTime now = DateTime.now();
  var _total;
  DatabaseHelper helper = DatabaseHelper ();
  List<Conta> _contas = List ();
  List<Orcamento> _orcamentos = List ();
  List<Movimentacao> _movimentacao = List ();
  List<Movimentacao> _movimentacaoOrcamento = List ();
  List<Usuario> usuario = List ();
  Orcamento newOrcamento;

  bool flagConta = false;
  bool flagOrcamentos = false;
  bool flagMovimentacao = false;

  @override
  void initState() {
    super.initState ();
    flagConta = false;
    flagOrcamentos = false;
    flagMovimentacao = false;
    _getAllOrcamentos();
    _getAllUsuarios ();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Contas Disponiveis",
            style: TextStyle(fontSize: 25.0, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: _fazTela(),
    );
  }

  Widget _fazTela() {
    if(flagConta == false || flagOrcamentos == false || flagMovimentacao == false){
      return Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 300.0),),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }else{
      if (_contas.length == 0) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 300.0, 30.0, 7.0),
                child: Text(
                  "Não há contas cadastradas",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 23.0),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  child: GestureDetector(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 53.0,
                    ),
                    onTap: () { _mostraCadastroContas();},
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        return Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 0.0),
            child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "     Nome",
                    style: TextStyle(color: Colors.black, fontSize: 24.0),
                  ),
                  Text(
                    "Saldo(R\$)",
                    style: TextStyle(color: Colors.black, fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _contas.length,
                itemBuilder: (context, index) {
                  return _criaListaTela(context, index);
                }),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(), color: Colors.grey),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  "Total",
                  style: TextStyle(fontSize: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Text("     (R\$)", style: TextStyle(fontSize: 20.0),),
                    Text(formatter.format(_total),  style: TextStyle(fontSize: 20.0),),
                  ],
                )
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  child: Text(
                    "Adicionar conta",
                    style: TextStyle(fontSize: 27.0),
                  ),
                  color: Colors.grey,
                  onPressed: () {
                    _mostraCadastroContas();
                  },
                ),
              ),
            ],
          ),
        ]);
      }
    }
  }

  Widget _criaListaTela(BuildContext context, int index) {
    decideCorConta(context, index);
    return Card(
      child: GestureDetector(
        child: Container(
          color: _contas[index].corConta,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(_contas[index].nomeConta,
                    style: TextStyle(fontSize: 25.0)),
                Text(
                  formatter.format(_contas[index].saldoConta),
                  style: TextStyle(fontSize: 25.0),
                ),
              ]),
        ),
        onTap: () {
          _mostraConta(conta: _contas[index]);
        },
      ),
    );
  }

  void _mostraConta({Conta conta}) async {
    final recConta = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TelaConta(
                  conta: conta,
                )));
    _getAllOrcamentos();
  }

  void _mostraCadastroContas({Conta contas}) async {
    final recConta = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroConta(
                  conta: contas,
                )));
    if (recConta != null) {
      if (contas != null) {
        await helper.updateConta(recConta);
        _getAllContas();
      } else {
        await helper.saveConta((recConta));
      }
      _getAllOrcamentos();
    }
  }
  void decideCorConta(BuildContext context, int index){
    switch (_contas[index].idCorConta) {
      case 1:
        {
          _contas[index].corConta = Colors.red;
        }
        break;
      case 2:
        {
          _contas[index].corConta = Colors.blue;
        }
        break;
      case 3:
        {
          _contas[index].corConta = Colors.indigo;
        }
        break;
      case 4:
        {
          _contas[index].corConta = Colors.orange;
        }
        break;
      case 5:
        {
          _contas[index].corConta = Colors.green;
        }
        break;
      case 6:
        {
          _contas[index].corConta = Colors.pinkAccent;
        }
        break;
      case 7:
        {
          _contas[index].corConta = Colors.yellow;
        }
        break;
      case 8:
        {
          _contas[index].corConta = Colors.limeAccent;
        }
        break;
      case 9:
        {
          _contas[index].corConta = Colors.pink;
        }
        break;
      case 10:
        {
          _contas[index].corConta = Colors.deepPurple;
        }
        break;
      case 11:
        {
          _contas[index].corConta = Colors.blueGrey;
        }
        break;
      case 12:
        {
          _contas[index].corConta = Colors.brown;
        }
        break;
    }
  }

  Future<void> _calculaTotal() async{
    _total = await helper.getSomaSaldoConta();
    setState(() {
      if(_total == null){
        _total = 0.0;
      }
    });
  }

  Future<void> _getAllContas() async{
    await helper.getAllConta().then((list) {
      setState(() {
        _contas = list;
      });
    });
  }

  Future<void> _getAllOrcamentos() async{
    int cont = 0;
    await helper.getAllOrcamento().then((list) {
        _orcamentos = list;
        /*if(_orcamentos.length != 0){
          do{
            var dataFimOrc = DateTime.parse(_orcamentos[cont].dataFimOrcamento);
            if(_orcamentos[cont].emUso == true){
              if(dataFimOrc.year <= now.year) {
                if (dataFimOrc.month <= now.month || dataFimOrc.year < now.year) {
                  if(dataFimOrc.day <= now.day || dataFimOrc.month < now.month || dataFimOrc.year < now.year) {
                    _orcamentos[cont].emUso = false;
                    newOrcamento.acumulaValorOrcamento = _orcamentos[cont].acumulaValorOrcamento;
                    newOrcamento.valorTotalOrcamento = _orcamentos[cont].valorTotalOrcamento;
                    newOrcamento.descricaoOrcamento = _orcamentos[cont].descricaoOrcamento;
                    newOrcamento.estorouLimiteOrcamento = false;
                    newOrcamento.diasRenovacao = _orcamentos[cont].diasRenovacao;
                    newOrcamento.dataInicioOrcamento = _orcamentos[cont].dataFimOrcamento;
                    var renovacaoEm = dataFimOrc.add(new Duration(days: _orcamentos[cont].diasRenovacao));
                    String formattedDateRen = DateFormat('yyyy-MM-dd').format(renovacaoEm);
                    newOrcamento.dataFimOrcamento = formattedDateRen;
                    newOrcamento.idCategoria = _orcamentos[cont].idCategoria;
                    newOrcamento.emUso = true;
                    if(_orcamentos[cont].acumulaValorOrcamento == true){
                      newOrcamento.valorAtualOrcamento = _orcamentos[cont].valorAtualOrcamento - _orcamentos[cont].valorTotalOrcamento;
                    }else {
                      newOrcamento.valorAtualOrcamento = 0.00;
                    }
                    helper.saveOrcamento(newOrcamento);
                    int mov = 0;
                    helper.getOrcamentoMovimentacao(_orcamentos[cont].idOrcamento).then((list){
                      _movimentacaoOrcamento = list;
                    });
                    do{
                      if(_movimentacaoOrcamento[mov].somadaOrcamento == false){
                        _movimentacaoOrcamento[mov].idOrcamento = newOrcamento.idOrcamento;
                        helper.updateMovimentacao(_movimentacaoOrcamento[mov]);
                      }
                    }while(mov < _movimentacaoOrcamento.length);
                    helper.updateOrcamento(_orcamentos[cont]);
                  }
                }
              }
            }
            cont++;
          }while(cont < _orcamentos.length);
        }*/
    });
    /*if( _orcamentos.length != 0) {
      cont = 0;
      var dataFimOrc = DateTime.parse(_orcamentos[cont].dataFimOrcamento);
      if (_orcamentos[cont].emUso == true) {
        if (dataFimOrc.year <= now.year) {
          if (dataFimOrc.month <= now.month || dataFimOrc.year < now.year) {
            if (dataFimOrc.day <= now.day || dataFimOrc.month < now.month ||
                dataFimOrc.year < now.year) {
              await _getAllOrcamentos();
            }
          }
        }
      }
    }*/
    await _getAllMovimentacao();
  }

  Future<void> _getAllMovimentacao() async{
    int aux = 0;
    int aux1 = 0;
    await _getAllContas();
    await helper.getAllMovimentacao().then((list) {
      setState(() {
        _movimentacao = list;
        /*if(_movimentacao.length != 0){
          print(_movimentacao);
          print(_contas);
          do{
            var dataMov = DateTime.parse(_movimentacao[aux].dataHoraMovimentacao);
            if(_movimentacao[aux].somadaConta == false){
              if(dataMov.year <= now.year) {
                if (dataMov.month <= now.month || dataMov.year < now.year) {
                  if(dataMov.day <= now.day || dataMov.month < now.month || dataMov.year < now.year){
                    if(_movimentacao[aux].tipoMovimentacao == "Saida"){
                      _movimentacao[aux].valorMovimentacao *= (-1);
                    }
                    int i = 0;
                    while(_movimentacao[aux].idConta != _contas[i].idConta){
                      i++;
                    }
                    _contas[i].saldoConta += _movimentacao[aux].valorMovimentacao;
                    _movimentacao[aux].somadaConta = true;
                    helper.updateMovimentacao(_movimentacao[aux]);
                    helper.updateConta(_contas[i]);
                  }
                }
              }
            }
            aux++;
          }while(aux < _movimentacao.length);
          do{
            var dataMov1 = DateTime.parse(_movimentacao[aux].dataHoraMovimentacao);
            if(_movimentacao[aux1].idOrcamento != null){
              if(_movimentacao[aux1].somadaOrcamento == false){
                if(dataMov1.year <= now.year) {
                  if (dataMov1.month <= now.month || dataMov1.year < now.year) {
                    if(dataMov1.day <= now.day || dataMov1.month < now.month || dataMov1.year < now.year){
                      int n = 0;
                      while(_movimentacao[aux1].idOrcamento != _orcamentos[n].idOrcamento){
                        n++;
                      }
                      double auxVar;
                      auxVar =  _movimentacao[aux1].valorMovimentacao;
                      if(_movimentacao[aux1].idCategoria == 3){
                        _orcamentos[n].valorAtualOrcamento += auxVar;
                      }else {
                        auxVar = auxVar * (-1);
                        _orcamentos[n].valorAtualOrcamento += auxVar;
                      }
                      _movimentacao[aux1].somadaOrcamento = true;
                      helper.updateMovimentacao(_movimentacao[aux]);
                      helper.updateOrcamento(_orcamentos[n]);
                    }
                  }
                }
              }
            }
            aux1++;
          }while(aux1 < _movimentacao.length);
        }*/
      });
    });
    /*if(_movimentacao.length != 0){
      await _getAllContas();
    }*/
    await _calculaTotal ();
    setState(() {
      flagMovimentacao = true;
      flagOrcamentos = true;
      flagConta = true;
    });
    
  }

  Future<void> _getAllUsuarios() async {
    await helper.getAllUsuarios().then((list) {
      setState(() {
        usuario = list;
      });
    });
  }
}
