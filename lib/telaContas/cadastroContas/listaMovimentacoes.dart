import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaContas.dart';
import 'package:controle_de_financas/telasCadastros/cadastroMovimentacao.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class ListaMovimentacoes extends StatefulWidget {
  @override
  _ListaMovimentacoesState createState() => _ListaMovimentacoesState();
}

class _ListaMovimentacoesState extends State<ListaMovimentacoes> {
  DatabaseHelper helper = DatabaseHelper();
  NumberFormat formatter = NumberFormat("00.00");

  List<Movimentacao> _movimentacao = List();
  List<Movimentacao> _movimentacaoFiltrada = List();

  List<Conta> _nomeConta = List();
  List<DropdownMenuItem<Conta>> _dropdownMenuConta = List();
  Conta _selectedConta;
  List<Conta> _contas = List();

  List<Categoria> _nomeCategoria = List();
  List<Categoria> _categorias = List();
  List<DropdownMenuItem<Categoria>> _dropdownMenuCategoria = List();
  Categoria _selectedCategoria;

  List<Orcamento> _orcamentoCategoria = List();
  List<Orcamento> _orcamentos = List();
  List<DropdownMenuItem<Orcamento>> _dropdownMenuOrcamento = List();
  Orcamento _selectedOrcamento;

  List<CartaoCredito> _cartoesCredito = List();
  List<DropdownMenuItem<CartaoCredito>> _dropdownMenuCartaoCredito = List();
  CartaoCredito _selectedCartaoCredito;

  int _radioValueNatureza = 4;
  int _radioValueTipo = -1;

  bool isExpanded = false;
  int auxCor = 0;
  var _totalMov;
  double _soma = 0;
  double valorMinimo = 0.00;
  double valorMaximo = 0.00;
  bool flagMov = false;
  bool flagConta = false;
  bool flagCart = false;
  bool flagCat = false;
  bool flagOrcs = false;

  final _valorMovimentacaoMinimoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _valorMovimentacaoMaximoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');

  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    flagMov = false;
    flagConta = false;
    flagCart = false;
    flagCat = false;
    flagOrcs = false;
    _getAllMovimentacao();
    _getAllContas();
    _getAllCartaoCredito();
    _getMovimentacaoConta();
    _getMovimentacaoCategoria();
    _getAllCategorias();
    _getOrcamentos();
    _getAllOrcamentos();
    _getCartaoCredito();
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

  void onChangeDropdownItemConta(Conta selectedConta) {
    setState(() {
      _selectedConta = selectedConta;
    });
  }

  void onChangeDropdownItemCartaoCredito(CartaoCredito selectedCartaoCredito) {
    setState(() {
      _selectedCartaoCredito = selectedCartaoCredito;
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

  void _mudarValorRadio(int value) {
    setState(() {
      switch (value) {
        case -1:
          {
            _radioValueTipo = -1;
            break;
          }
        case 0:
          {
            _radioValueTipo = 0;
            break;
          }
        case 1:
          {
            _radioValueTipo = 1;
            break;
          }
      }
      switch (value) {
        case 2:
          {
            _radioValueNatureza = 2;
            break;
          }
        case 3:
          {
            _radioValueNatureza = 3;
            break;
          }
        case 4:
          {
            _radioValueNatureza = 4;
            break;
          }
      }
    });
  }

  Future<Null> _selectDate1(BuildContext context) async {
    var dataFim = selectedDate1.add(new Duration(days: 9999999));
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate1,
        firstDate: DateTime(2020, 01),
        lastDate: DateTime(dataFim.year));
    if (picked != null && picked != selectedDate1) {
      setState(() {
       final difference = selectedDate2.difference(picked).inMicroseconds;
        if(difference < 0){
          setState(() {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Atenção"),
                    content:
                    Text(
                        "A data inicial não pode ser maior que a data final!"
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          });
        }else{
          selectedDate1 = picked;
        }
      });
    }
  }

  Future<Null> _selectDate2(BuildContext context) async {
    var dataFim = selectedDate2.add(new Duration(days: 9999999));
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate2,
        firstDate: DateTime(2020, 01),
        lastDate: DateTime(dataFim.year));
    if (picked != null && picked != selectedDate2) {
      setState(() {
        final difference = selectedDate1.difference(picked).inMicroseconds;
        if(difference > 0 ){
          setState(() {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Atenção"),
                    content:
                    Text(
                        "A data inicial não pode ser maior que a data final!"
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          });
        }else{
          selectedDate2 = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          resizeToAvoidBottomInset : false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(65.0),
            child: AppBar(
              title: Text(
                "Movimentações",
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
              backgroundColor: Colors.black,
              centerTitle: true,
            ),
          ),
          body: _fazTela(),
        ),
    );
  }

  Widget _fazTela() {
      if (_movimentacaoFiltrada.length == 0) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 300.0, 30.0, 7.0),
                child: Text(
                  "Voce não tem movimentaçoes",
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
                      _mostraCadastroMovimentacao();
                    },
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        if(_movimentacao.length == 0){
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  color: Colors.grey,
                  child: Container(
                    child: SingleChildScrollView(
                      child:  ExpansionTile(
                        onExpansionChanged: (bool expanding) =>
                            setState(() => this.isExpanded = expanding),
                        title: Wrap(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(left: 100.0),),
                            Text("Filtrar por:",
                                style: TextStyle(
                                    fontSize: 26.0,
                                    color: isExpanded ? Colors.black : Colors.black)),
                            Padding(padding: EdgeInsets.only(left: 30.0),),
                            Icon(Icons.filter_list),
                          ],
                        ),
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.60,
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Conta:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _selectedConta = null;
                                        });},
                                      ),
                                    ],
                                  ),
                                  DropdownButton(
                                    style: TextStyle(fontSize: 25.0, color: Colors.black),
                                    disabledHint: Text("Sem conta cadastrada"),
                                    hint: Text("Selecione a conta"),
                                    value: _selectedConta,
                                    items: _dropdownMenuConta,
                                    onChanged: (valor) {
                                      setState(() {
                                        onChangeDropdownItemConta(valor);
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Cartão de credito:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _selectedCartaoCredito = null;
                                        });},
                                      ),
                                    ],
                                  ),
                                  DropdownButton(
                                    disabledHint: escolheTextoDisableCartao(),
                                    hint: Text("Selecione o cartão de credito"),
                                    value: _selectedCartaoCredito,
                                    items: _dropdownMenuCartaoCredito,
                                    onChanged: (valor) {
                                      setState(() {
                                        onChangeDropdownItemCartaoCredito(valor);
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Categoria:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _selectedCategoria = null;
                                        });},
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
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Orcamento:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _selectedOrcamento = null;
                                        });},
                                      ),
                                    ],
                                  ),
                                  DropdownButton(
                                    disabledHint: Text("Sem orçamento cadastrado"),
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
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Valor:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          valorMinimo = 0.00;
                                          valorMaximo = 0.00;
                                        });},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      FlatButton(
                                          child: Row(
                                            children: <Widget>[
                                              Text("Valor minimo: "),
                                              Text(valorMinimo.toString()),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Escolha o valor minimo"),
                                                      content:
                                                      TextField(
                                                        controller: _valorMovimentacaoMinimoController,
                                                        decoration: InputDecoration(labelText: "Valor"),
                                                        keyboardType: TextInputType.number,
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text("OK"),
                                                          onPressed: () {
                                                            setState(() {
                                                              valorMinimo = _valorMovimentacaoMinimoController.numberValue;
                                                            });
                                                            if(_valorMovimentacaoMinimoController.numberValue > valorMaximo){
                                                              setState(() {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: Text("Atenção"),
                                                                        content:
                                                                        Text(
                                                                            "O valor minimo não pode ser maior que o valor maximo!"
                                                                        ),
                                                                        actions: <Widget>[
                                                                          FlatButton(
                                                                            child: Text("OK"),
                                                                            onPressed: () {
                                                                              setState(() {
                                                                                valorMaximo = valorMinimo;
                                                                              });
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    });
                                                              });
                                                            }else{
                                                              setState(() {
                                                                valorMinimo = _valorMovimentacaoMinimoController.numberValue;
                                                                Navigator.pop(context);
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            });
                                          }
                                      ),
                                      FlatButton(
                                          child: Row(
                                            children: <Widget>[
                                              Text("Valor maximo: "),
                                              Text(valorMaximo.toString()),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Escolha o valor maximo"),
                                                      content:
                                                      TextField(
                                                        controller: _valorMovimentacaoMaximoController,
                                                        decoration: InputDecoration(labelText: "Valor"),
                                                        keyboardType: TextInputType.number,
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text("OK"),
                                                          onPressed: () {
                                                            if(_valorMovimentacaoMaximoController.numberValue < valorMinimo){
                                                              setState(() {
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: Text("Atenção"),
                                                                        content:
                                                                        Text(
                                                                            "O valor maximo não pode ser menor que o valor minimo!"
                                                                        ),
                                                                        actions: <Widget>[
                                                                          FlatButton(
                                                                            child: Text("OK"),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    });
                                                              });
                                                            }else{
                                                              setState(() {
                                                                valorMaximo = _valorMovimentacaoMaximoController.numberValue;
                                                                Navigator.pop(context);
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            });
                                          }
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Operação:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _radioValueNatureza = 4;
                                        });},
                                      ),
                                    ],
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
                                        padding: EdgeInsets.only(left: 20.0),
                                      ),
                                      Radio(
                                        value: 3,
                                        groupValue: _radioValueNatureza,
                                        onChanged: _mudarValorRadio,

                                      ),
                                      Text("Crédito"),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                      ),
                                      Radio(
                                        value: 4,
                                        groupValue: _radioValueNatureza,
                                        onChanged: _mudarValorRadio,
                                      ),
                                      Text("Ambos"),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Tipo:",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          _radioValueTipo = -1;
                                        });},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio(
                                        value: 0,
                                        groupValue: _radioValueTipo,
                                        onChanged: _mudarValorRadio,
                                      ),
                                      Text("Saida"),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                      ),
                                      Radio(
                                        value: 1,
                                        groupValue: _radioValueTipo,
                                        onChanged: _mudarValorRadio,

                                      ),
                                      Text("Entrada"),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                      ),
                                      Radio(
                                        value: -1,
                                        groupValue: _radioValueTipo,
                                        onChanged: _mudarValorRadio,
                                      ),
                                      Text("Ambos"),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("Data da inicial: ", style: TextStyle(fontSize: 18.0),),
                                      RaisedButton(
                                        onPressed: (){
                                          _selectDate1(context);
                                        },
                                        child: Text("${selectedDate1.day}/${selectedDate1.month}/${selectedDate1.year}".split(' ')[0]),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          selectedDate1 = DateTime.now();
                                          selectedDate2 = DateTime.now();
                                        });},
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("Data da final: ", style: TextStyle(fontSize: 18.0),),
                                      RaisedButton(
                                        onPressed: (){
                                          _selectDate2(context);
                                        },
                                        child: Text("${selectedDate2.day}/${selectedDate2.month}/${selectedDate2.year}".split(' ')[0]),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                        onPressed: (){setState(() {
                                          selectedDate1 = DateTime.now();
                                          selectedDate2 = DateTime.now();
                                        });},
                                      ),
                                    ],
                                  ),
                                  Padding(padding:EdgeInsets.only(top: 20.0) ,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Text("Limpar", style: TextStyle(color: Colors.white),),
                                        onTap: (){
                                          setState(() {
                                            _selectedConta = null;
                                            _selectedCartaoCredito = null;
                                            _selectedCategoria = null;
                                            _selectedOrcamento = null;
                                            valorMinimo = 0.00;
                                            valorMaximo = 0.00;
                                            _radioValueNatureza = 4;
                                            _radioValueTipo = -1;
                                            selectedDate1 = DateTime.now();
                                            selectedDate2 = DateTime.now();
                                          });
                                        },
                                      ),
                                      GestureDetector(
                                        child: Text("Pesquisar", style: TextStyle(color: Colors.white),),
                                        onTap: (){
                                          setState(() {
                                            _getAllMovimentacao();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30.0, 250.0, 30.0, 7.0),
                  child: Text(
                    "Ops, nada encontrada com esses filtros",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 23.0),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 168.0),),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        child: Text(
                          "Adicionar Movimentação",
                          style: TextStyle(fontSize: 27.0),
                        ),
                        color: Colors.grey,
                        onPressed: () {
                          _mostraCadastroMovimentacao();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }else{
          return Column(children: <Widget>[
            Card(
              color: Colors.grey,
              child: Container(
                child: SingleChildScrollView(
                  child:  ExpansionTile(
                    onExpansionChanged: (bool expanding) =>
                        setState(() => this.isExpanded = expanding),
                    title: Wrap(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(left: 100.0),),
                        Text("Filtrar por:",
                            style: TextStyle(
                                fontSize: 26.0,
                                color: isExpanded ? Colors.black : Colors.black)),
                        Padding(padding: EdgeInsets.only(left: 30.0),),
                        Icon(Icons.filter_list),
                      ],
                    ),
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.60,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Conta:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _selectedConta = null;
                                    });},
                                  ),
                                ],
                              ),
                              DropdownButton(
                                style: TextStyle(fontSize: 25.0, color: Colors.black),
                                disabledHint: Text("Sem conta cadastrada"),
                                hint: Text("Selecione a conta"),
                                value: _selectedConta,
                                items: _dropdownMenuConta,
                                onChanged: (valor) {
                                  setState(() {
                                    onChangeDropdownItemConta(valor);
                                  });
                                },
                                isExpanded: true,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Cartão de credito:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _selectedCartaoCredito = null;
                                    });},
                                  ),
                                ],
                              ),
                              DropdownButton(
                                disabledHint: escolheTextoDisableCartao(),
                                hint: Text("Selecione o cartão de credito"),
                                value: _selectedCartaoCredito,
                                items: _dropdownMenuCartaoCredito,
                                onChanged: (valor) {
                                  setState(() {
                                    onChangeDropdownItemCartaoCredito(valor);
                                  });
                                },
                                isExpanded: true,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Categoria:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _selectedCategoria = null;
                                    });},
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
                                  });
                                },
                                isExpanded: true,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Orcamento:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _selectedOrcamento = null;
                                    });},
                                  ),
                                ],
                              ),
                              DropdownButton(
                                disabledHint: Text("Sem orçamento cadastrado"),
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
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Valor:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      valorMinimo = 0.00;
                                      valorMaximo = 0.00;
                                    });},
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  FlatButton(
                                      child: Row(
                                        children: <Widget>[
                                          Text("Valor minimo: "),
                                          Text(valorMinimo.toString()),
                                        ],
                                      ),
                                      onPressed: (){
                                        setState(() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Escolha o valor minimo"),
                                                  content:
                                                  TextField(
                                                    controller: _valorMovimentacaoMinimoController,
                                                    decoration: InputDecoration(labelText: "Valor"),
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("OK"),
                                                      onPressed: () {
                                                        setState(() {
                                                          valorMinimo = _valorMovimentacaoMinimoController.numberValue;
                                                        });
                                                        if(_valorMovimentacaoMinimoController.numberValue > valorMaximo){
                                                          setState(() {
                                                            showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    title: Text("Atenção"),
                                                                    content:
                                                                    Text(
                                                                        "O valor minimo não pode ser maior que o valor maximo!"
                                                                    ),
                                                                    actions: <Widget>[
                                                                      FlatButton(
                                                                        child: Text("OK"),
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            valorMaximo = valorMinimo;
                                                                          });
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          });
                                                        }else{
                                                          setState(() {
                                                            valorMinimo = _valorMovimentacaoMinimoController.numberValue;
                                                            Navigator.pop(context);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        });
                                      }
                                  ),
                                  FlatButton(
                                      child: Row(
                                        children: <Widget>[
                                          Text("Valor maximo: "),
                                          Text(valorMaximo.toString()),
                                        ],
                                      ),
                                      onPressed: (){
                                        setState(() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Escolha o valor maximo"),
                                                  content:
                                                  TextField(
                                                    controller: _valorMovimentacaoMaximoController,
                                                    decoration: InputDecoration(labelText: "Valor"),
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("OK"),
                                                      onPressed: () {
                                                        if(_valorMovimentacaoMaximoController.numberValue < valorMinimo){
                                                          setState(() {
                                                            showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    title: Text("Atenção"),
                                                                    content:
                                                                    Text(
                                                                        "O valor maximo não pode ser menor que o valor minimo!"
                                                                    ),
                                                                    actions: <Widget>[
                                                                      FlatButton(
                                                                        child: Text("OK"),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          });
                                                        }else{
                                                          setState(() {
                                                            valorMaximo = _valorMovimentacaoMaximoController.numberValue;
                                                            Navigator.pop(context);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        });
                                      }
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Operação:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _radioValueNatureza = 4;
                                    });},
                                  ),
                                ],
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
                                    padding: EdgeInsets.only(left: 20.0),
                                  ),
                                  Radio(
                                    value: 3,
                                    groupValue: _radioValueNatureza,
                                    onChanged: _mudarValorRadio,

                                  ),
                                  Text("Crédito"),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                  ),
                                  Radio(
                                    value: 4,
                                    groupValue: _radioValueNatureza,
                                    onChanged: _mudarValorRadio,
                                  ),
                                  Text("Ambos"),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Tipo:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      _radioValueTipo = -1;
                                    });},
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Radio(
                                    value: 0,
                                    groupValue: _radioValueTipo,
                                    onChanged: _mudarValorRadio,
                                  ),
                                  Text("Saida"),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                  ),
                                  Radio(
                                    value: 1,
                                    groupValue: _radioValueTipo,
                                    onChanged: _mudarValorRadio,

                                  ),
                                  Text("Entrada"),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                  ),
                                  Radio(
                                    value: -1,
                                    groupValue: _radioValueTipo,
                                    onChanged: _mudarValorRadio,
                                  ),
                                  Text("Ambos"),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text("Data da inicial: ", style: TextStyle(fontSize: 18.0),),
                                  RaisedButton(
                                    onPressed: (){
                                      _selectDate1(context);
                                    },
                                    child: Text("${selectedDate1.day}/${selectedDate1.month}/${selectedDate1.year}".split(' ')[0]),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      selectedDate1 = DateTime.now();
                                      selectedDate2 = DateTime.now();
                                    });},
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text("Data da final: ", style: TextStyle(fontSize: 18.0),),
                                  RaisedButton(
                                    onPressed: (){
                                      _selectDate2(context);
                                    },
                                    child: Text("${selectedDate2.day}/${selectedDate2.month}/${selectedDate2.year}".split(' ')[0]),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 18.0, color: Colors.white,),
                                    onPressed: (){setState(() {
                                      selectedDate1 = DateTime.now();
                                      selectedDate2 = DateTime.now();
                                    });},
                                  ),
                                ],
                              ),
                              Padding(padding:EdgeInsets.only(top: 20.0) ,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Text("Limpar", style: TextStyle(color: Colors.white),),
                                    onTap: (){
                                      setState(() {
                                        _selectedConta = null;
                                        _selectedCartaoCredito = null;
                                        _selectedCategoria = null;
                                        _selectedOrcamento = null;
                                        valorMinimo = 0.00;
                                        valorMaximo = 0.00;
                                        _radioValueNatureza = 4;
                                        _radioValueTipo = -1;
                                        selectedDate1 = DateTime.now();
                                        selectedDate2 = DateTime.now();
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Text("Pesquisar", style: TextStyle(color: Colors.white),),
                                    onTap: (){
                                      setState(() {
                                        _getAllMovimentacao();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child:  ListView.builder(
                    itemCount: _movimentacao.length,
                    itemBuilder: (context, index) {
                      return _criaListaTela(context, index);
                    }),
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all(), color: Colors.grey),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Total de movimentações",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    _totalMov.toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all(), color: Colors.grey),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Soma",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    "(R\$)${formatter.format(_soma)}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text(
                      "Adicionar Movimentação",
                      style: TextStyle(fontSize: 27.0),
                    ),
                    color: Colors.grey,
                    onPressed: () {
                      _mostraCadastroMovimentacao();
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
    _getCorMovimentacao (context, index);
    return Card(
      color: _nomeConta[auxCor].corConta,
      child: ExpansionTile(
        onExpansionChanged: (bool expanding) =>
            setState(() => this.isExpanded = expanding),
        title: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            Text(_movimentacao[index].motivoMovimentacao,
                style: TextStyle(
                    fontSize: 20.0,
                    color: isExpanded ? Colors.black : Colors.black)),
            mostraValorBarra(index),
          ],
        ),
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                        Text(
                          "Motivo: ",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        Text(
                          _movimentacao[index].motivoMovimentacao,
                          style: TextStyle(fontSize: 18.0),
                        ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Wrap(
                      children: <Widget>[
                        Text(
                          "Data: ",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        Text(
                          _movimentacao[index].dataHoraMovimentacao.toString(),
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Text("Operação: ",style: TextStyle(fontSize: 18.0, color: Colors.white),),
                    Text(_movimentacao[index].naturezaOperacaoMovimentacao,style: TextStyle(fontSize: 18.0),),
                    Padding(padding: EdgeInsets.only(left: 60.0),),
                    Text("Tipo: ",style: TextStyle(fontSize: 18.0, color: Colors.white),),
                    Text(_movimentacao[index].tipoMovimentacao,style: TextStyle(fontSize: 18.0),)
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Text("Categoria: ",style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    nomeDaCategoria(index),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Text("Orçamento: ",style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    nomeDoOrcamento(index),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Text("Valor: ",style: TextStyle(fontSize: 22.0, color: Colors.white)),
                    mostraValor(index),
                  ],
                ),
                Padding(padding: EdgeInsets.all(6.0)),
                Row(
                  children: <Widget>[
                    Text("Cartao: ",style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    nomeDoCartaoCredito(index),
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0)),
                Row(
                  children: <Widget>[
                    Text("Conta: ",style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    nomeDaConta(index),
                    Padding(padding: EdgeInsets.only(left: 150.0),),
                    IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.delete),
                      onPressed: (){
                        setState(() {
                          showDialog(context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text("Excluir movimentação?"),
                                  content: Text("Deseja realmente excluir esta movimentação?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Cancelar"),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("Excluir"),
                                      onPressed: (){
                                        if(_movimentacao[index].naturezaOperacaoMovimentacao == "Transferencia"){
                                          int t = 0;
                                          int c1 = 0;
                                          int c2 = 0;

                                          while(_movimentacao[index].idMovimentacao != _movimentacao[t].idTransferencia){
                                            t++;
                                          }

                                          while(_movimentacao[index].idConta != _nomeConta[c1].idConta){
                                            c1++;
                                          }

                                          while(_movimentacao[t].idConta != _nomeConta[c2].idConta){
                                            c2++;
                                          }
                                          _nomeConta[c1].saldoConta -= _movimentacao[index].valorMovimentacao;
                                          _nomeConta[c2].saldoConta -= _movimentacao[t].valorMovimentacao;
                                          helper.deleteMovimentacao(_movimentacao[index].idMovimentacao);
                                          helper.deleteMovimentacao(_movimentacao[t].idMovimentacao);
                                          helper.updateConta(_nomeConta[c1]);
                                          helper.updateConta(_nomeConta[c2]);
                                        }else{
                                          var dataMov = DateTime.parse(_movimentacaoFiltrada[index].dataHoraMovimentacao);
                                          if(dataMov.year <= now.year) {
                                            if (dataMov.month <= now.month || dataMov.year < now.year) {
                                              if(dataMov.day <= now.day || dataMov.month < now.month || dataMov.year < now.year){
                                              if (_movimentacao[index]
                                                  .naturezaOperacaoMovimentacao ==
                                                  "Crédito") {
                                                int i = 0;
                                                while (_movimentacao[index]
                                                    .idConta !=
                                                    _nomeConta[i].idConta) {
                                                  i++;
                                                }
                                                if (_movimentacao[index]
                                                    .idOrcamento != null) {
                                                  int o = 0;
                                                  while (_movimentacao[index]
                                                      .idOrcamento !=
                                                      _orcamentoCategoria[o]
                                                          .idOrcamento) {
                                                    o++;
                                                  }
                                                  _orcamentoCategoria[o]
                                                      .valorAtualOrcamento -=
                                                      _movimentacao[index]
                                                          .valorMovimentacao;
                                                  helper.updateOrcamento(
                                                      _orcamentoCategoria[o]);
                                                }
                                                helper.deleteMovimentacao(
                                                    _movimentacao[index]
                                                        .idMovimentacao);
                                              } else {
                                                int i = 0;
                                                while (_movimentacao[index]
                                                    .idConta !=
                                                    _nomeConta[i].idConta) {
                                                  i++;
                                                }
                                                if (_movimentacao[index]
                                                    .idOrcamento != null) {
                                                  int o = 0;
                                                  while (_movimentacao[index]
                                                      .idOrcamento !=
                                                      _orcamentoCategoria[o]
                                                          .idOrcamento) {
                                                    o++;
                                                  }
                                                  _orcamentoCategoria[o]
                                                      .valorAtualOrcamento +=
                                                      _movimentacao[index]
                                                          .valorMovimentacao;
                                                  helper.updateOrcamento(
                                                      _orcamentoCategoria[o]);
                                                }
                                                _nomeConta[i].saldoConta -=
                                                    _movimentacao[index]
                                                        .valorMovimentacao;
                                                helper.updateConta(
                                                    _nomeConta[i]);

                                                helper.deleteMovimentacao(
                                                    _movimentacao[index]
                                                        .idMovimentacao);
                                              }
                                            }else{
                                                helper.deleteMovimentacao(
                                                    _movimentacao[index]
                                                        .idMovimentacao);
                                              }
                                            }else{
                                              helper.deleteMovimentacao(
                                                  _movimentacao[index]
                                                      .idMovimentacao);
                                            }
                                          }else{
                                            helper.deleteMovimentacao(
                                                _movimentacao[index]
                                                    .idMovimentacao);
                                          }
                                        }
                                        Navigator.pop(context);
                                        setState(() {
                                          _getAllMovimentacao();
                                          _getAllContas();
                                          _getAllCartaoCredito();
                                          _getMovimentacaoConta();
                                          _getMovimentacaoCategoria();
                                          _getAllCategorias();
                                          _getOrcamentos();
                                          _getAllOrcamentos();
                                          _getCartaoCredito();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }
                          );
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mostraValorBarra(int index){
    if(_movimentacao[index].tipoMovimentacao == "Entrada"){
      return Text("+${formatter.format(_movimentacao[index].valorMovimentacao)}",style: TextStyle(fontSize: 22.0, color: isExpanded ? Colors.black : Colors.black),);
    }else{
      return Text(formatter.format(_movimentacao[index].valorMovimentacao),style: TextStyle(fontSize: 22.0, color: isExpanded ? Colors.black : Colors.black),);
    }
  }

  Widget mostraValor(int index){
    if(_movimentacao[index].tipoMovimentacao == "Entrada"){
      return Text("+${formatter.format(_movimentacao[index].valorMovimentacao)}",style: TextStyle(fontSize: 22.0),);
    }else{
      return Text(formatter.format(_movimentacao[index].valorMovimentacao),style: TextStyle(fontSize: 22.0),);
    }
  }

  void _mostraCadastroMovimentacao({Movimentacao movimentacoes}) async {
    final recMovimentacao = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroMovimentacao(
                  movimentacao: movimentacoes,
                )));
    if (recMovimentacao != null) {
      await helper.saveMovimentacao((recMovimentacao));
    }
    _getAllMovimentacao();
    _getAllContas();
    _getAllCartaoCredito();
    _getMovimentacaoConta();
    _getMovimentacaoCategoria();
    _getAllCategorias();
    _getOrcamentos();
    _getAllOrcamentos();
    _getCartaoCredito();
  }

  Widget nomeDaCategoria(int index){
    int o = 0;
    while(_movimentacao[index].idCategoria != _nomeCategoria[o].idCategoria){
      o++;
    }
    return Text(_nomeCategoria[o].nomeCategoria,style: TextStyle(fontSize: 18.0, color: Colors.white));
  }

  Widget nomeDoOrcamento(int index){
    int n = 0;
    if(_movimentacao[index].idOrcamento != null){
      while(_movimentacao[index].idOrcamento != _orcamentoCategoria[n].idOrcamento){
        n++;
      }
      return Text(_orcamentoCategoria[n].descricaoOrcamento,style: TextStyle(fontSize: 18.0, color: Colors.white));
    }else{
      return Text("-",style: TextStyle(fontSize: 18.0, color: Colors.white));
    }
  }

  Widget nomeDoCartaoCredito(int index){
    int n = 0;
    if(_movimentacao[index].idCartaoCredito != null){
      while(_movimentacao[index].idCartaoCredito != _cartoesCredito[n].idCartaoCredito){
        n++;
      }
      return Text(_cartoesCredito[n].nomeCartaoCredito,style: TextStyle(fontSize: 18.0, color: Colors.white));
    }else{
      return Text("-",style: TextStyle(fontSize: 18.0, color: Colors.white));
    }
  }

  Widget nomeDaConta(int index){
    int i = 0;
    while(_movimentacao[index].idConta != _nomeConta[i].idConta){
      i++;
    }
    return Text(_nomeConta[i].nomeConta,style: TextStyle(fontSize: 18.0));
  }

  Widget  escolheTextoDisableCartao(){
    if(_selectedConta == null){
      return Text("Sem conta selecionada");
    }else{
      return Text("Nenhum cartão cadastrado para esta conta");
    }
  }

  Future<Null> _requestPop() async{
    Navigator.pop(context);
    Navigator.pop(context);
    await Navigator.push(context, MaterialPageRoute(
        builder: (context) => MostraContas(
        )));
  }

  void _getCorMovimentacao(BuildContext context, int index) {
    auxCor = 0;
    while(_movimentacao[index].idConta != _nomeConta[auxCor].idConta){
      auxCor++;
    }
    switch (_nomeConta[auxCor].idCorConta) {
      case 1:
        {
          _nomeConta[auxCor].corConta = Colors.red;
        }
        break;
      case 2:
        {
          _nomeConta[auxCor].corConta = Colors.blue;
        }
        break;
      case 3:
        {
          _nomeConta[auxCor].corConta = Colors.indigo;
        }
        break;
      case 4:
        {
          _nomeConta[auxCor].corConta = Colors.orange;
        }
        break;
      case 5:
        {
          _nomeConta[auxCor].corConta = Colors.green;
        }
        break;
      case 6:
        {
          _nomeConta[auxCor].corConta = Colors.pinkAccent;
        }
        break;
      case 7:
        {
          _nomeConta[auxCor].corConta = Colors.yellow;
        }
        break;
      case 8:
        {
          _nomeConta[auxCor].corConta = Colors.limeAccent;
        }
        break;
      case 9:
        {
          _nomeConta[auxCor].corConta = Colors.pink;
        }
        break;
      case 10:
        {
          _nomeConta[auxCor].corConta = Colors.deepPurple;
        }
        break;
      case 11:
        {
          _nomeConta[auxCor].corConta = Colors.blueGrey;
        }
        break;
      case 12:
        {
          _nomeConta[auxCor].corConta = Colors.brown;
        }
        break;
    }
  }

  Future<void> _getAllMovimentacao() async {
    int data = 0;
    _movimentacao = [];
    _soma = 0;
    await helper.getAllMovimentacao().then((list) {
      setState(() {
        _movimentacaoFiltrada = list;
        do{
          var dataMov = DateTime.parse(_movimentacaoFiltrada[data].dataHoraMovimentacao);
              if(dataMov.year >= selectedDate1.year && dataMov.year <= selectedDate2.year) {
                if ((dataMov.month >= selectedDate1.month ||
                    dataMov.year > selectedDate1.year) &&
                    (dataMov.month <= selectedDate2.month || dataMov.year < selectedDate2.year)) {
                  if ((dataMov.day >= selectedDate1.day ||
                      dataMov.month > selectedDate1.month ||  dataMov.year > selectedDate1.year) &&
                      (dataMov.day <= selectedDate2.day || dataMov.month < selectedDate2.month || dataMov.year < selectedDate2.year)) {
            if (_selectedConta != null) {
              if (_movimentacaoFiltrada[data].idConta ==
                  _selectedConta.idConta) {
                if (_selectedCartaoCredito != null) {
                  if (_movimentacaoFiltrada[data].idCartaoCredito ==
                      _selectedCartaoCredito.idCartaoCredito) {
                    if (_selectedCategoria != null) {
                      if (_movimentacaoFiltrada[data].idCategoria ==
                          _selectedCategoria.idCategoria) {
                        if (_selectedOrcamento != null) {
                          if (_movimentacaoFiltrada[data].idOrcamento ==
                              _selectedOrcamento.idOrcamento) {
                            if (_radioValueNatureza == 4) {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueNatureza == 2 &&
                                  _movimentacaoFiltrada[data]
                                      .naturezaOperacaoMovimentacao ==
                                      "Débito") {
                                if (_radioValueTipo == -1) {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 0 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Saida") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 1 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Entrada") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueNatureza == 3 &&
                                    _movimentacaoFiltrada[data]
                                        .naturezaOperacaoMovimentacao ==
                                        "Crédito") {
                                  if (_radioValueTipo == -1) {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 0 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Saida") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      if (_radioValueTipo == 1 &&
                                          _movimentacaoFiltrada[data]
                                              .tipoMovimentacao == "Entrada") {
                                        if (valorMinimo == 0.00 &&
                                            valorMaximo == 0.00) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo &&
                                              _radioValueTipo == 1)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (((_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1)) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo &&
                                                _radioValueTipo == 0)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            } else {
                                              if (_radioValueTipo == -1) {
                                                if ((_movimentacaoFiltrada[data]
                                                    .valorMovimentacao >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao <=
                                                        valorMaximo) ||
                                                    (_movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) >= valorMinimo &&
                                                        _movimentacaoFiltrada[data]
                                                            .valorMovimentacao *
                                                            (-1) <=
                                                            valorMaximo)) {
                                                  _movimentacao.add(
                                                      _movimentacaoFiltrada[data]);
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 4) {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 2 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao == "Débito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueNatureza == 3 &&
                                  _movimentacaoFiltrada[data]
                                      .naturezaOperacaoMovimentacao ==
                                      "Crédito") {
                                if (_radioValueTipo == -1) {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 0 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Saida") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 1 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Entrada") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (_selectedOrcamento != null) {
                        if (_movimentacaoFiltrada[data].idOrcamento ==
                            _selectedOrcamento.idOrcamento) {
                          if (_radioValueNatureza == 4) {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 2 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao == "Débito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueNatureza == 3 &&
                                  _movimentacaoFiltrada[data]
                                      .naturezaOperacaoMovimentacao ==
                                      "Crédito") {
                                if (_radioValueTipo == -1) {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 0 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Saida") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 1 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Entrada") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  if (_selectedCategoria != null) {
                    if (_movimentacaoFiltrada[data].idCategoria ==
                        _selectedCategoria.idCategoria) {
                      if (_selectedOrcamento != null) {
                        if (_movimentacaoFiltrada[data].idOrcamento ==
                            _selectedOrcamento.idOrcamento) {
                          if (_radioValueNatureza == 4) {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 2 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao == "Débito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueNatureza == 3 &&
                                  _movimentacaoFiltrada[data]
                                      .naturezaOperacaoMovimentacao ==
                                      "Crédito") {
                                if (_radioValueTipo == -1) {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 0 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Saida") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 1 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Entrada") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    if (_selectedOrcamento != null) {
                      if (_movimentacaoFiltrada[data].idOrcamento ==
                          _selectedOrcamento.idOrcamento) {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (_radioValueNatureza == 4) {
                        if (_radioValueTipo == -1) {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 0 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Saida") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 1 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Entrada") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 2 &&
                            _movimentacaoFiltrada[data]
                                .naturezaOperacaoMovimentacao == "Débito") {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 3 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Crédito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            } else {
              if (_selectedCartaoCredito != null) {
                if (_movimentacaoFiltrada[data].idCartaoCredito ==
                    _selectedCartaoCredito.idCartaoCredito) {
                  if (_selectedCategoria != null) {
                    if (_movimentacaoFiltrada[data].idCategoria ==
                        _selectedCategoria.idCategoria) {
                      if (_selectedOrcamento != null) {
                        if (_movimentacaoFiltrada[data].idOrcamento ==
                            _selectedOrcamento.idOrcamento) {
                          if (_radioValueNatureza == 4) {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 2 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao == "Débito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueNatureza == 3 &&
                                  _movimentacaoFiltrada[data]
                                      .naturezaOperacaoMovimentacao ==
                                      "Crédito") {
                                if (_radioValueTipo == -1) {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 0 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Saida") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  } else {
                                    if (_radioValueTipo == 1 &&
                                        _movimentacaoFiltrada[data]
                                            .tipoMovimentacao == "Entrada") {
                                      if (valorMinimo == 0.00 &&
                                          valorMaximo == 0.00) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo &&
                                            _radioValueTipo == 1)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (((_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1)) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo &&
                                              _radioValueTipo == 0)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          } else {
                                            if (_radioValueTipo == -1) {
                                              if ((_movimentacaoFiltrada[data]
                                                  .valorMovimentacao >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao <=
                                                      valorMaximo) ||
                                                  (_movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) >= valorMinimo &&
                                                      _movimentacaoFiltrada[data]
                                                          .valorMovimentacao *
                                                          (-1) <=
                                                          valorMaximo)) {
                                                _movimentacao.add(
                                                    _movimentacaoFiltrada[data]);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    if (_selectedOrcamento != null) {
                      if (_movimentacaoFiltrada[data].idOrcamento ==
                          _selectedOrcamento.idOrcamento) {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (_radioValueNatureza == 4) {
                        if (_radioValueTipo == -1) {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 0 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Saida") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 1 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Entrada") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 2 &&
                            _movimentacaoFiltrada[data]
                                .naturezaOperacaoMovimentacao == "Débito") {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 3 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Crédito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              } else {
                if (_selectedCategoria != null) {
                  if (_movimentacaoFiltrada[data].idCategoria ==
                      _selectedCategoria.idCategoria) {
                    if (_selectedOrcamento != null) {
                      if (_movimentacaoFiltrada[data].idOrcamento ==
                          _selectedOrcamento.idOrcamento) {
                        if (_radioValueNatureza == 4) {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 2 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Débito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueNatureza == 3 &&
                                _movimentacaoFiltrada[data]
                                    .naturezaOperacaoMovimentacao ==
                                    "Crédito") {
                              if (_radioValueTipo == -1) {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 0 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Saida") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (_radioValueTipo == 1 &&
                                      _movimentacaoFiltrada[data]
                                          .tipoMovimentacao == "Entrada") {
                                    if (valorMinimo == 0.00 &&
                                        valorMaximo == 0.00) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo &&
                                          _radioValueTipo == 1)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (((_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1)) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo &&
                                            _radioValueTipo == 0)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        } else {
                                          if (_radioValueTipo == -1) {
                                            if ((_movimentacaoFiltrada[data]
                                                .valorMovimentacao >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao <=
                                                    valorMaximo) ||
                                                (_movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) >=
                                                    valorMinimo &&
                                                    _movimentacaoFiltrada[data]
                                                        .valorMovimentacao *
                                                        (-1) <= valorMaximo)) {
                                              _movimentacao.add(
                                                  _movimentacaoFiltrada[data]);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (_radioValueNatureza == 4) {
                        if (_radioValueTipo == -1) {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 0 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Saida") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 1 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Entrada") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 2 &&
                            _movimentacaoFiltrada[data]
                                .naturezaOperacaoMovimentacao == "Débito") {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 3 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Crédito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  if (_selectedOrcamento != null) {
                    if (_movimentacaoFiltrada[data].idOrcamento ==
                        _selectedOrcamento.idOrcamento) {
                      if (_radioValueNatureza == 4) {
                        if (_radioValueTipo == -1) {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 0 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Saida") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 1 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Entrada") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 2 &&
                            _movimentacaoFiltrada[data]
                                .naturezaOperacaoMovimentacao == "Débito") {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueNatureza == 3 &&
                              _movimentacaoFiltrada[data]
                                  .naturezaOperacaoMovimentacao == "Crédito") {
                            if (_radioValueTipo == -1) {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 0 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Saida") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (_radioValueTipo == 1 &&
                                    _movimentacaoFiltrada[data]
                                        .tipoMovimentacao == "Entrada") {
                                  if (valorMinimo == 0.00 &&
                                      valorMaximo == 0.00) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <= valorMaximo &&
                                        _radioValueTipo == 1)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (((_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1)) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo &&
                                          _radioValueTipo == 0)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      } else {
                                        if (_radioValueTipo == -1) {
                                          if ((_movimentacaoFiltrada[data]
                                              .valorMovimentacao >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao <=
                                                  valorMaximo) ||
                                              (_movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) >=
                                                  valorMinimo &&
                                                  _movimentacaoFiltrada[data]
                                                      .valorMovimentacao *
                                                      (-1) <= valorMaximo)) {
                                            _movimentacao.add(
                                                _movimentacaoFiltrada[data]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  } else {
                    if (_radioValueNatureza == 4) {
                      if (_radioValueTipo == -1) {
                        if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                          _movimentacao.add(_movimentacaoFiltrada[data]);
                        } else {
                          if ((_movimentacaoFiltrada[data].valorMovimentacao >=
                              valorMinimo &&
                              _movimentacaoFiltrada[data].valorMovimentacao <=
                                  valorMaximo && _radioValueTipo == 1)) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if (((_movimentacaoFiltrada[data]
                                .valorMovimentacao * (-1)) >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao *
                                    (-1) <= valorMaximo &&
                                _radioValueTipo == 0)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (_radioValueTipo == -1) {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo) ||
                                    (_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueTipo == 0 &&
                            _movimentacaoFiltrada[data].tipoMovimentacao ==
                                "Saida") {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 1 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Entrada") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (_radioValueNatureza == 2 &&
                          _movimentacaoFiltrada[data]
                              .naturezaOperacaoMovimentacao == "Débito") {
                        if (_radioValueTipo == -1) {
                          if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                            _movimentacao.add(_movimentacaoFiltrada[data]);
                          } else {
                            if ((_movimentacaoFiltrada[data]
                                .valorMovimentacao >= valorMinimo &&
                                _movimentacaoFiltrada[data].valorMovimentacao <=
                                    valorMaximo && _radioValueTipo == 1)) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if (((_movimentacaoFiltrada[data]
                                  .valorMovimentacao * (-1)) >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (_radioValueTipo == -1) {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo) ||
                                      (_movimentacaoFiltrada[data]
                                          .valorMovimentacao * (-1) >=
                                          valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) <=
                                              valorMaximo)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          if (_radioValueTipo == 0 &&
                              _movimentacaoFiltrada[data].tipoMovimentacao ==
                                  "Saida") {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 1 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Entrada") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (_radioValueNatureza == 3 &&
                            _movimentacaoFiltrada[data]
                                .naturezaOperacaoMovimentacao == "Crédito") {
                          if (_radioValueTipo == -1) {
                            if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                              _movimentacao.add(_movimentacaoFiltrada[data]);
                            } else {
                              if ((_movimentacaoFiltrada[data]
                                  .valorMovimentacao >= valorMinimo &&
                                  _movimentacaoFiltrada[data]
                                      .valorMovimentacao <= valorMaximo &&
                                  _radioValueTipo == 1)) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if (((_movimentacaoFiltrada[data]
                                    .valorMovimentacao * (-1)) >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1) <=
                                        valorMaximo && _radioValueTipo == 0)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (_radioValueTipo == -1) {
                                    if ((_movimentacaoFiltrada[data]
                                        .valorMovimentacao >= valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao <=
                                            valorMaximo) ||
                                        (_movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) >=
                                            valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) <=
                                                valorMaximo)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            if (_radioValueTipo == 0 &&
                                _movimentacaoFiltrada[data].tipoMovimentacao ==
                                    "Saida") {
                              if (valorMinimo == 0.00 && valorMaximo == 0.00) {
                                _movimentacao.add(_movimentacaoFiltrada[data]);
                              } else {
                                if ((_movimentacaoFiltrada[data]
                                    .valorMovimentacao >= valorMinimo &&
                                    _movimentacaoFiltrada[data]
                                        .valorMovimentacao <= valorMaximo &&
                                    _radioValueTipo == 1)) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if (((_movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1)) >=
                                      valorMinimo && _movimentacaoFiltrada[data]
                                      .valorMovimentacao * (-1) <=
                                      valorMaximo && _radioValueTipo == 0)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (_radioValueTipo == -1) {
                                      if ((_movimentacaoFiltrada[data]
                                          .valorMovimentacao >= valorMinimo &&
                                          _movimentacaoFiltrada[data]
                                              .valorMovimentacao <=
                                              valorMaximo) ||
                                          (_movimentacaoFiltrada[data]
                                              .valorMovimentacao * (-1) >=
                                              valorMinimo &&
                                              _movimentacaoFiltrada[data]
                                                  .valorMovimentacao * (-1) <=
                                                  valorMaximo)) {
                                        _movimentacao.add(
                                            _movimentacaoFiltrada[data]);
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              if (_radioValueTipo == 1 &&
                                  _movimentacaoFiltrada[data]
                                      .tipoMovimentacao == "Entrada") {
                                if (valorMinimo == 0.00 &&
                                    valorMaximo == 0.00) {
                                  _movimentacao.add(
                                      _movimentacaoFiltrada[data]);
                                } else {
                                  if ((_movimentacaoFiltrada[data]
                                      .valorMovimentacao >= valorMinimo &&
                                      _movimentacaoFiltrada[data]
                                          .valorMovimentacao <= valorMaximo &&
                                      _radioValueTipo == 1)) {
                                    _movimentacao.add(
                                        _movimentacaoFiltrada[data]);
                                  } else {
                                    if (((_movimentacaoFiltrada[data]
                                        .valorMovimentacao * (-1)) >=
                                        valorMinimo &&
                                        _movimentacaoFiltrada[data]
                                            .valorMovimentacao * (-1) <=
                                            valorMaximo &&
                                        _radioValueTipo == 0)) {
                                      _movimentacao.add(
                                          _movimentacaoFiltrada[data]);
                                    } else {
                                      if (_radioValueTipo == -1) {
                                        if ((_movimentacaoFiltrada[data]
                                            .valorMovimentacao >= valorMinimo &&
                                            _movimentacaoFiltrada[data]
                                                .valorMovimentacao <=
                                                valorMaximo) ||
                                            (_movimentacaoFiltrada[data]
                                                .valorMovimentacao * (-1) >=
                                                valorMinimo &&
                                                _movimentacaoFiltrada[data]
                                                    .valorMovimentacao * (-1) <=
                                                    valorMaximo)) {
                                          _movimentacao.add(
                                              _movimentacaoFiltrada[data]);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
          data++;
        }while(data < _movimentacaoFiltrada.length);
        _totalMov = _movimentacao.length;
        for(var aux = 0; aux < _movimentacao.length; aux++){
          _soma += _movimentacao[aux].valorMovimentacao;
        }
      });
    });
  flagMov = true;
  }

  Future<void> _getMovimentacaoConta() async {
    await helper.getMovimentacaoConta().then((list) {
      setState(() {
        _nomeConta = list;
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

  Future<void> _getMovimentacaoCategoria() async {
    await helper.getCategoriaMovimento().then((list) {
      setState(() {
        _nomeCategoria = list;
      });
    });
  }

  Future<void> _getAllCategorias() async {
    await helper.getAllCategoria().then((list) {
      setState(() {
        _categorias = list;
        _dropdownMenuCategoria = buildDropdownMenuCategorias(_categorias);
      });
    });
    flagCat = true;
  }

  Future<void> _getOrcamentos() async {
    await helper.getAllCategoriaOrcamento().then((list) {
      setState(() {
        _orcamentoCategoria = list;
      });
    });
  }

  Future<void> _getAllOrcamentos() async {
    await helper.getAllOrcamento().then((list) {
      setState(() {
        _orcamentos = list;
        _dropdownMenuOrcamento = buildDropdownMenuOrcamentos(_orcamentos);
      });
    });
    flagOrcs = true;
  }


  Future<void> _getCartaoCredito() async {
    await helper.getAllMovimentacaoCartaoCredito().then((list) {
      setState(() {
        _cartoesCredito = list;
      });
    });
  }

  Future<void> _getAllCartaoCredito() async {
    await helper.getAllCartaoCredito().then((list) {
      setState(() {
        _cartoesCredito = list;
        _dropdownMenuCartaoCredito = buildDropdownMenuCartaoCredito(_cartoesCredito);
      });
    });
    flagCart = true;
  }
}
