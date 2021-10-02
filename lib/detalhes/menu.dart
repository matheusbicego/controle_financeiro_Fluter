import 'dart:io';

import 'package:controle_de_financas/banco/bancoHelper.dart';
import 'package:controle_de_financas/banco/crudConta.dart';
import 'package:controle_de_financas/banco/crudUsuario.dart';
import 'package:controle_de_financas/detalhes/telaConfiguracoes.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaContas.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaMovimentacoes.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/listaOrcamentos.dart';
import 'package:controle_de_financas/telaContas/cadastroContas/transferencia.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DatabaseHelper helper = DatabaseHelper();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.grey,
                ),
          ),
          ListTile(
            leading: Icon(Icons.assignment_ind),
            title: Text('Contas'),
            onTap: (){
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MostraContas(
                )));
              },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Movimentações'),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ListaMovimentacoes(
                )
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.import_export),
            title: Text('Transferencia'),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Transferencia(
                  )
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.offline_pin),
            title: Text('Orçamentos'),
            onTap: ()  {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MostraOrcamentos(
                ),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: ()  {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MostraConfiguracoes(
                ),
              ));
            },
          ),
          Padding(padding: EdgeInsets.only(top: 150.0),),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: ()  {
                showDialog(context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text("Deseja realmente sair?"),
                        content: Text(""),
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
                              helper.close();
                              exit(0);
                            },
                          ),
                        ],
                      );
                    }
                );
            },
          ),
        ],
      ),
    );
  }
}