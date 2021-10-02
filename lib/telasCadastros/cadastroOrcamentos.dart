import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class CadastroOrcamento extends StatefulWidget {
  @override
  _CadastroOrcamentoState createState() => _CadastroOrcamentoState();

  Orcamento orcamento;

  CadastroOrcamento({this.orcamento});
}

class _CadastroOrcamentoState extends State<CadastroOrcamento> {

  static DateTime now = DateTime.now();
  static String formattedDate = DateFormat('yyyy/MM/dd - kk:mm').format(now);

  final _descricaoOrcamentoController = TextEditingController();
  final _valorOrcamentoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _diasController = TextEditingController();

  final _descricaoOrcamentoFocus = FocusNode();
  final _valorOrcamentoFocus = FocusNode();
  final _diasFocus = FocusNode();
  final _categoriaFocus = FocusNode();

  DatabaseHelper helper = DatabaseHelper();
  Orcamento _orcamentoEditado;

  List<Categoria> _categorias = List();
  List<DropdownMenuItem<Categoria>> _dropdownMenuCategoria = List();
  Categoria _selectedCategoria;

  void initState() {
    super.initState();
    if (widget.orcamento == null) {
      _orcamentoEditado = Orcamento();
      _orcamentoEditado.acumulaValorOrcamento = false;
    } else {
      _orcamentoEditado = Orcamento.fromMap(widget.orcamento.toMap());

      _descricaoOrcamentoController.text = _orcamentoEditado.descricaoOrcamento;
      _valorOrcamentoController
          .updateValue(_orcamentoEditado.valorTotalOrcamento);
      _diasController.text = _orcamentoEditado.diasRenovacao.toString();
    }
    _getAllCategorias();
    if(_orcamentoEditado.valorAtualOrcamento == null){
      _orcamentoEditado.valorAtualOrcamento = 0.0;
    }
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

  void onChangeDropdownItemCategoria(Categoria selectedCategoria) {
    setState(() {
      _selectedCategoria = selectedCategoria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65.0),
          child: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              _orcamentoEditado.descricaoOrcamento ?? "Novo Orcamento",
              style: TextStyle(fontSize: 25.0, color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              descricaoValor(),
              decideCategoria(),
              decideRenovacao(),
              Padding(padding: EdgeInsets.all(60.0),),
              salvaOrcamento(),
            ],
          ),
        ));
  }

  Widget descricaoValor() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 3.0))),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          ),
          TextField(
            controller: _descricaoOrcamentoController,
            focusNode: _descricaoOrcamentoFocus,
            decoration: InputDecoration(labelText: "Descrição do orcamento"),
            onChanged: (text) {
              setState(() {
                _orcamentoEditado.descricaoOrcamento = text;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          ),
          TextField(
            controller: _valorOrcamentoController,
            focusNode: _valorOrcamentoFocus,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(labelText: "Limite do orcamento"),
            onChanged: (text) {
              setState(() {
                var aux = _valorOrcamentoController.numberValue;
                if (aux == null) {
                  aux = 0.0;
                }
                _orcamentoEditado.valorTotalOrcamento = aux;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.all(05.0),
          ),
        ],
      ),
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
              focusNode: _categoriaFocus,
              onChanged: (valor) {
                setState(() {
                  onChangeDropdownItemCategoria(valor);
                  _orcamentoEditado.idCategoria = _selectedCategoria.idCategoria;
                });
              },
              isExpanded: true,
            ),
          ],
        ));
  }

  Widget decideRenovacao(){
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(10.0),),
        Row(
          children: <Widget>[
            Text("Renovação do orçamento a cada:(dias) ", style: TextStyle(fontSize: 20.0),),
          ],
        ),
            TextFormField(
                controller: _diasController,
                focusNode: _diasFocus,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
              onChanged: (text) {
                setState(() {
                  var aux = int.parse(_diasController.text);
                  if (aux == null) {
                    aux = 0;
                  }
                  _orcamentoEditado.diasRenovacao = aux;
                });
              },
            ),
        Padding(padding: EdgeInsets.all(10.0),),
                Row(
                  children: <Widget>[
                    Text("Acumular sobra ou falta para a proxima renovação? ",style: TextStyle(fontSize: 14.874),),
                    Checkbox(
                        value: _orcamentoEditado.acumulaValorOrcamento,
                        onChanged:(value){
                          setState(() {
                            _orcamentoEditado.acumulaValorOrcamento = value;
                          });
                        }
                    ),
                  ],
                ),
      ],
    );
  }

  Widget salvaOrcamento(){
    return FlatButton(
      child: Text(
        "Salvar",
        style: TextStyle(fontSize: 27.0),
      ),
      color: Colors.grey,
      onPressed: () {
        if(_orcamentoEditado.diasRenovacao != null){
          var renovacaoEm = now.add(new Duration(days: _orcamentoEditado.diasRenovacao));
          String formattedDateNow = DateFormat('yyyy-MM-dd').format(now);
          String formattedDateRen = DateFormat('yyyy-MM-dd').format(renovacaoEm);
          _orcamentoEditado.dataInicioOrcamento = formattedDateNow.toString();
          _orcamentoEditado.dataFimOrcamento = formattedDateRen.toString();
        }else{
          FocusScope.of(context)
              .requestFocus(_diasFocus);
        }
        if(_orcamentoEditado.descricaoOrcamento != null && _orcamentoEditado.descricaoOrcamento.isNotEmpty){
          if(_orcamentoEditado.valorTotalOrcamento != null){
            if(_orcamentoEditado.idCategoria != null){
              if(_orcamentoEditado.diasRenovacao != null){
                Navigator.pop(context, _orcamentoEditado);
              }else{
                FocusScope.of(context)
                    .requestFocus(_diasFocus);
              }
            }else{
              FocusScope.of(context)
                  .requestFocus(_categoriaFocus);
            }
          }else{
            FocusScope.of(context)
                .requestFocus(_valorOrcamentoFocus);
          }
        }else{
          FocusScope.of(context)
              .requestFocus(_descricaoOrcamentoFocus);
        }
      },
    );
  }

  Future<void> _getAllCategorias() async {
    await helper.getAllCategoria().then((list) {
      setState(() {
        _categorias = list;
        _dropdownMenuCategoria = buildDropdownMenuCategorias(_categorias);

        if(_orcamentoEditado.idCategoria == null){
          _selectedCategoria = _dropdownMenuCategoria[0].value;
        }else{
          int c = 0;
          while(_orcamentoEditado.idCategoria != _categorias[c].idCategoria){
            c++;
          }
          _selectedCategoria = _dropdownMenuCategoria[c].value;
        }
        _orcamentoEditado.idCategoria = _selectedCategoria.idCategoria;
      });
    });
  }
}
