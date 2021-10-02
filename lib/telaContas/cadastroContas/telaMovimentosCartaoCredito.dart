import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class TelaMovimentosCartaoCredito extends StatefulWidget {
  @override
  _TelaMovimentosCartaoCreditoState createState() => _TelaMovimentosCartaoCreditoState();

  CartaoCredito cartaoCredito;

  TelaMovimentosCartaoCredito({this.cartaoCredito});
}

class _TelaMovimentosCartaoCreditoState extends State<TelaMovimentosCartaoCredito> {
  DatabaseHelper helper = DatabaseHelper();

  NumberFormat formatter = NumberFormat("00.00");

  List<Movimentacao> _movimentacao = List();
  List<Movimentacao> _movimentacaoFiltrada = List();

  CartaoCredito _cartaoCreditoAtual = CartaoCredito();

  List<Conta> _nomeConta = List();

  List<Categoria> _nomeCategoria = List();
  List<Categoria> _categorias = List();
  List<DropdownMenuItem<Categoria>> _dropdownMenuCategoria = List();
  Categoria _selectedCategoria;

  List<Orcamento> _orcamentoCategoria = List();
  List<Orcamento> _orcamentos = List();
  List<DropdownMenuItem<Orcamento>> _dropdownMenuOrcamento = List();
  Orcamento _selectedOrcamento;

  var _totalMov;
  bool isExpanded = false;
  int auxCor = 0;
  double _soma = 0;
  double valorMinimo = 0.00;
  double valorMaximo = 0.00;
  final _valorMovimentacaoMinimoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _valorMovimentacaoMaximoController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  static DateTime selectedDate1 = DateTime.now();
  static DateTime selectedDate2 = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cartaoCreditoAtual = CartaoCredito.fromMap(widget.cartaoCredito.toMap());
    _getAllMovimentacao();
    _getMovimentacaoConta();
    _getMovimentacaoCategoria();
    _getOrcamentos();
    _getAllOrcamentos();
    _getAllCategorias();
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
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          title: Text(
            _cartaoCreditoAtual.nomeCartaoCredito,
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
    if (_movimentacaoFiltrada.length == 0) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 300.0, 30.0, 7.0),
              child: Text(
                "Voce não tem movimentaçoes para este cartão",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 23.0),
              ),
            ),
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
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
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
                                          _selectedCategoria = null;
                                          _selectedOrcamento = null;
                                          valorMinimo = 0.00;
                                          valorMaximo = 0.00;
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
                      height: MediaQuery.of(context).size.height * 0.62,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
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
                                      _selectedCategoria = null;
                                      _selectedOrcamento = null;
                                      valorMinimo = 0.00;
                                      valorMaximo = 0.00;
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
            child: ListView.builder(
                itemCount: _movimentacao.length,
                itemBuilder: (context, index) {
                  return _criaListaTela(context, index);
                }),
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
            Text(formatter.format(_movimentacao[index].valorMovimentacao),style: TextStyle(fontSize: 22.0, color: isExpanded ? Colors.black : Colors.black),),
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
                    Text(formatter.format(_movimentacao[index].valorMovimentacao),style: TextStyle(fontSize: 22.0),),
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
                                          int i = 0;
                                          while(_movimentacao[index].idConta != _nomeConta[i].idConta){
                                            i++;
                                          }
                                          if(_movimentacao[index].idOrcamento != null){
                                            int o = 0;
                                            while(_movimentacao[index].idOrcamento != _orcamentoCategoria[o].idOrcamento){
                                              o++;
                                            }
                                            _orcamentoCategoria[o].valorAtualOrcamento -= _movimentacao[index].valorMovimentacao;
                                            helper.updateOrcamento(_orcamentoCategoria[o]);
                                          }
                                          helper.deleteMovimentacao(_movimentacao[index].idMovimentacao);
                                        }
                                        Navigator.pop(context);
                                        _getAllMovimentacao();
                                        _getMovimentacaoConta();
                                        _getMovimentacaoCategoria();
                                        _getOrcamentos();
                                        _getAllOrcamentos();
                                        _getAllCategorias();
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

  Widget nomeDaConta(int index){
    int i = 0;
    while(_movimentacao[index].idConta != _nomeConta[i].idConta){
      i++;
    }
    return Text(_nomeConta[i].nomeConta,style: TextStyle(fontSize: 18.0));
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
    await helper.getCartaoCreditoMovimentacao(_cartaoCreditoAtual.idCartaoCredito).then((list) {
      setState(() {
        _movimentacaoFiltrada = list;
        do{
          var dataMov = DateTime.parse(_movimentacaoFiltrada[data].dataHoraMovimentacao);
          if(dataMov.year >= selectedDate1.year && dataMov.month >= selectedDate1.month && dataMov.day >= selectedDate1.day && dataMov.year <= selectedDate2.year && dataMov.month <= selectedDate2.month && dataMov.day <= selectedDate2.day){
            if(_selectedCategoria != null){
              if(_movimentacaoFiltrada[data].idCategoria == _selectedCategoria.idCategoria){
                if(_selectedOrcamento != null){
                  if(_movimentacaoFiltrada[data].idOrcamento == _selectedOrcamento.idOrcamento){
                    if(valorMinimo == 0.00 && valorMaximo == 0.00){
                      _movimentacao.add(_movimentacaoFiltrada[data]);
                    }else{
                      if(_movimentacaoFiltrada[data].valorMovimentacao >= valorMinimo && _movimentacaoFiltrada[data].valorMovimentacao <= valorMaximo){
                        _movimentacao.add(_movimentacaoFiltrada[data]);
                      }
                    }
                  }
                }else{
                  if(valorMinimo == 0.00 && valorMaximo == 0.00){
                    _movimentacao.add(_movimentacaoFiltrada[data]);
                  }else{
                    if(_movimentacaoFiltrada[data].valorMovimentacao >= valorMinimo && _movimentacaoFiltrada[data].valorMovimentacao <= valorMaximo){
                      _movimentacao.add(_movimentacaoFiltrada[data]);
                    }
                  }
                }
              }
            }else{
              if(_selectedOrcamento != null){
                if(_movimentacaoFiltrada[data].idOrcamento == _selectedOrcamento.idOrcamento){
                  if(valorMinimo == 0.00 && valorMaximo == 0.00){
                    _movimentacao.add(_movimentacaoFiltrada[data]);
                  }else{
                    if(_movimentacaoFiltrada[data].valorMovimentacao >= valorMinimo && _movimentacaoFiltrada[data].valorMovimentacao <= valorMaximo){
                      _movimentacao.add(_movimentacaoFiltrada[data]);
                    }
                  }
                }
              }else{
                if(valorMinimo == 0.00 && valorMaximo == 0.00){
                  _movimentacao.add(_movimentacaoFiltrada[data]);
                }else{
                  if(_movimentacaoFiltrada[data].valorMovimentacao >= valorMinimo && _movimentacaoFiltrada[data].valorMovimentacao <= valorMaximo){
                    _movimentacao.add(_movimentacaoFiltrada[data]);
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
        _orcamentoCategoria = list;
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
  }

  Future<void> _getAllOrcamentos() async {
    await helper.getAllOrcamento().then((list) {
      setState(() {
        _orcamentos = list;
        _dropdownMenuOrcamento = buildDropdownMenuOrcamentos(_orcamentos);
      });
    });
  }

}
