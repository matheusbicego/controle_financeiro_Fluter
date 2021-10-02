import 'dart:core';

final String cartaoCreditoTable = "CartaoCreditoTable";
final String idCartaoCreditoColumn = "idCartaoCreditoColumn";
final String nomeCartaoCreditoColumn = "nomeCartaoCreditoColumn";
final String dataInicioCartaoCreditoColumn = "dataInicioCartaoCreditoColumn";
final String idContaCartaoCreditoColumn = "idContaCartaoCreditoColumn";

class CartaoCredito {

  int idCartaoCredito;
  String nomeCartaoCredito;
  String dataInicioCartaoCredito;
  int idConta;

  CartaoCredito();

  CartaoCredito.fromMap(Map map){
    idCartaoCredito = map[idCartaoCreditoColumn];
    nomeCartaoCredito = map[nomeCartaoCreditoColumn];
    dataInicioCartaoCredito = map[dataInicioCartaoCreditoColumn];
    idConta = map[idContaCartaoCreditoColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeCartaoCreditoColumn: nomeCartaoCredito,
      dataInicioCartaoCreditoColumn: dataInicioCartaoCredito,
      idContaCartaoCreditoColumn: idConta,
    };
    if(idCartaoCredito != null){
      map[idCartaoCreditoColumn] = idCartaoCredito;
    }
    return map;
  }

  @override
  String toString() {
    return "CartaoCredito(idCartaoCredito: $idCartaoCredito,nomeCartaoCredito: $nomeCartaoCredito, dataInicioCartaoCredito:$dataInicioCartaoCredito, idConta: $idConta)";
  }


}




