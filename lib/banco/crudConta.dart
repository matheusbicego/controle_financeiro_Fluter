import 'dart:core';
import 'package:flutter/rendering.dart';

final String contaTable = "contaTable";
final String idContaColumn = "idContaColumn";
final String nomeContaColumn = "nomeContaColumn";
final String saldoContaColumn = "saldoContaColumn";
final String idCorContaColumn = "idCorContaColumn";
final String dataContaColumn = "dataContaColumn";
final String limiteChequeEspecialContaColumn = "limiteContaChequeEspecialColumn";

class Conta {
  int idConta;
  String nomeConta;
  double saldoConta;
  int idCorConta = 8;
  String dataConta;
  double limiteChequeEspecialConta;
  Color corConta;

  Conta();

  Conta.fromMap(Map map){
    idConta = map[idContaColumn];
    nomeConta = map[nomeContaColumn];
    saldoConta = map[saldoContaColumn];
    idCorConta = map[idCorContaColumn];
    dataConta = map[dataContaColumn];
    limiteChequeEspecialConta = map[limiteChequeEspecialContaColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeContaColumn: nomeConta,
      saldoContaColumn: saldoConta,
      idCorContaColumn: idCorConta,
      dataContaColumn: dataConta,
      limiteChequeEspecialContaColumn: limiteChequeEspecialConta,
    };
    if(idConta != null){
      map[idContaColumn] = idConta;
    }
    return map;
  }

  @override
  String toString() {
    return "contaTable(idConta: $idConta, nomeConta: $nomeConta, saldoConta: $saldoConta, corConta: $idCorConta, dataConta: $dataConta, limiteChequeEspecialConta: $limiteChequeEspecialConta";
  }


}




