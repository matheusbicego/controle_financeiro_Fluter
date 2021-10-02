import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/telaOrcamento.dart';
import 'package:controle_de_financas/telasCadastros/cadastroOrcamentos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:intl/intl.dart';

class MostraOrcamentos extends StatefulWidget {
  @override
  _MostraOrcamentosState createState() => _MostraOrcamentosState();
}

class _MostraOrcamentosState extends State<MostraOrcamentos> {
  DatabaseHelper helper = DatabaseHelper();
  List<Orcamento> _orcamentos = List();
  List<Categoria> _nomeCategoria = List();
  static DateTime now = DateTime.now();
  static String formattedDate = DateFormat('<dd/MM/yyyy>').format(now);
  NumberFormat formatter = NumberFormat("00.00");
  double _somaGasto;
  double _somaTotal;
  double _somaDisponivel;
  double _porcentagem;
  double _valorDisponivel;

  @override
  void initState() {
    super.initState();
    _getAllOrcamentos();

    _getSomaGastoOrcamento();
    _getSomaTotalOrcamento();
    _getOrcamentoCategoria();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          title: Text(
            "Orçamentos",
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
      ),
      body: _fazTela(),
    );
  }

  Widget _fazTela() {
    if (_orcamentos.length == 0) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 300.0, 30.0, 7.0),
              child: Text(
                "Não há orcamentos cadastrados",
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
                  onTap: () {
                    _mostraCadastroOrcamento();
                  },
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
            ),
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20.0),),
                Row(
                  children: <Widget>[
                    //Padding()
                    Text("Soma do valor gasto: ", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                    Text(formatter.format(_somaGasto),style: TextStyle(fontSize: 18.0)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 5.0),),
                Row(
                  children: <Widget>[
                    //Padding()
                    Text("Soma do valor disponivel: ", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                    Text(formatter.format(_somaDisponivel),style: TextStyle(fontSize: 18.0)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 5.0),),
                Row(
                  children: <Widget>[
                    //Padding()
                    Text("Soma total dos orçamentos: ", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                    Text(formatter.format(_somaTotal),style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 05.0),),
          listaOrcamentos(),
          adicionarOrcamento(),
        ],
      );
    }
  }

  Widget listaOrcamentos(){
    return Expanded(
      child: ListView.builder(
          itemCount: _orcamentos.length,
          itemBuilder: (context, index) {
            return _criaListaTela(context, index);
          }),
    );
  }

  Widget _criaListaTela(BuildContext context, int index) {
    Color corBarra = Colors.blue;
    Color corBarraSombra = Colors.blueAccent;
      if(_orcamentos[index].valorAtualOrcamento < 0){
        corBarra = Colors.green;
        corBarraSombra = Colors.greenAccent;
      }
      if(_orcamentos[index].valorAtualOrcamento > _orcamentos[index].valorTotalOrcamento){
        corBarra = Colors.red;
        corBarraSombra = Colors.redAccent;
      }
      _porcentagem = (_orcamentos[index].valorAtualOrcamento / _orcamentos[index].valorTotalOrcamento)*100;
      _valorDisponivel = _orcamentos[index].valorTotalOrcamento - _orcamentos[index].valorAtualOrcamento;
      if(_orcamentos[index].valorAtualOrcamento < 0){
        _porcentagem = 0;
      }
    return Card(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("  Valor atual", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 60.0),),
                  Column(
                    children: <Widget>[
                      _mostraCategoria(index),
                      Padding(padding: EdgeInsets.only(left: 75.0),),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 53.0),),
                  Column(
                    children: <Widget>[
                      Text("Valor Total",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                    ],
                  )
                ],
              ),
              RoundedProgressBar(
                style: RoundedProgressBarStyle(
                  backgroundProgress: Colors.grey,
                  colorBorder: Colors.black,
                  colorProgress: corBarra,
                  colorProgressDark: corBarraSombra,
                ),
                childLeft: Text(formatter.format(_orcamentos[index].valorAtualOrcamento),
                    style: TextStyle(color: Colors.white)),
                percent: _porcentagem,
                childCenter: Text(_orcamentos[index].descricaoOrcamento, style: TextStyle(fontSize: 20.0, color: Colors.white),),
                childRight: Text(formatter.format(_orcamentos[index].valorTotalOrcamento)),
              ),
              Row(
                children: <Widget>[
                  Text("  Disponivel: ", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Text(formatter.format(_valorDisponivel)),
                  Text("   Renovação: ", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Text(_orcamentos[index].dataFimOrcamento, style:TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  //Text($)
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0),)
            ],
          ),
        ),
        onTap: (){
          _mostraOrcamento(orcamento: _orcamentos[index]);
        },
      ),
    );
  }

  void _mostraOrcamento({Orcamento orcamento}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TelaOrcamento(
              orcamento : orcamento,
            )));
    _getAllOrcamentos();
    _getSomaGastoOrcamento();
    _getSomaTotalOrcamento();
  }

  Widget adicionarOrcamento(){
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
            child: Text(
              "Adicionar Orcamento",
              style: TextStyle(fontSize: 27.0),
            ),
            color: Colors.grey,
            onPressed: () {
              _mostraCadastroOrcamento();
            },
          ),
        ),
      ],
    );
  }

  Widget _mostraCategoria(int index){
    int i = 0;
    while(_orcamentos[index].idCategoria != _nomeCategoria[i].idCategoria){
      i++;
    }
    return Text(_nomeCategoria[i].nomeCategoria, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),);
  }

  void _mostraCadastroOrcamento({Orcamento orcamento}) async {
    final recOrcamento = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroOrcamento(
                  orcamento: orcamento,
                )));
    if (recOrcamento != null) {
      if (orcamento != null) {
        await helper.updateOrcamento(recOrcamento);
      } else {
        await helper.saveOrcamento((recOrcamento));
      }
      setState(() {
        _getAllOrcamentos();
        _getOrcamentoCategoria();
        _getSomaGastoOrcamento();
        _getSomaTotalOrcamento();
      });
    }
  }

  Future<void> _getAllOrcamentos() async {
    await helper.getAllOrcamento().then((list) {
      setState(() {
        _orcamentos = list;
      });
    });
  }

  Future<void> _getSomaGastoOrcamento() async{
    _somaGasto = await helper.getSomaGastoOrcamento();
    setState(() {
      if(_somaGasto == null){
        _somaGasto = 0.0;
      }
    });
  }

  Future<void> _getSomaTotalOrcamento() async{
    _somaTotal = await helper.getSomaTotalOrcamento();
    setState(() {
      if(_somaTotal == null){
        _somaTotal = 0.0;
      }
    });
    setState(() {
      _somaDisponivel = _somaTotal - _somaGasto;
      if(_somaDisponivel == null){
        _somaDisponivel = 0.0;
      }
    });
  }

  Future<void> _getOrcamentoCategoria() async {
    await helper.getOrcamentoCategoria().then((list) {
      setState(() {
        _nomeCategoria = list;
      });
    });
  }

}

