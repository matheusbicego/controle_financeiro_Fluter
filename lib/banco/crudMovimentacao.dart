import 'dart:core';

final String movimentacaoTable = "movimentacaoTable";
final String idMovimentacaoColumn = "idMovimentacaoColumn";
final String tipoMovimentacaoColumn = "tipoMovimentacaoColumn";
final String valorMovimentacaoColumn = "valorMovimentacaoColumn";
final String naturezaOperacaoMovimentacaoColumn = "naturezaOperacaoMovimentacaoColumn";
final String motivoMovimentacaoColumn = "motivoMovimentacaoColumn";
final String dataHoraMovimentacaoColumn = "dataHoraMovimentacaoColumn";
final String somadaContaColumn = "somadaContaColumn";
final String somadaOrcamentoColumn = "somadaOrcamentoColumn";
final String idContaMovimentacaoColumn = "idContaMovimentacaoColumn";
final String idCartaoCreditoMovimentacaoColumn = "idCartaoCreditoMovimentacaoColumn";
final String idCategoriaMovimentacaoColumn = "idCategoriaMovimentacaoColumn";
final String idMovimentacaoTransferenciaColumn = "idMovimentacaoTransferenciaColumn";
final String idOrcamentoMovimentacaoColumn = "idOrcamentoMovimentacaoColumn";

class Movimentacao {

  int idMovimentacao;
  String tipoMovimentacao;
  double valorMovimentacao;
  String naturezaOperacaoMovimentacao;
  String motivoMovimentacao;
  String dataHoraMovimentacao;
  bool somadaConta;
  bool somadaOrcamento;
  int idConta;
  int idOrcamento;
  int idCartaoCredito;
  int idCategoria;
  int idTransferencia;

  Movimentacao();

  Movimentacao.fromMap(Map map){
    idMovimentacao = map[idMovimentacaoColumn];
    tipoMovimentacao = map[tipoMovimentacaoColumn];
    valorMovimentacao = map[valorMovimentacaoColumn];
    naturezaOperacaoMovimentacao = map[naturezaOperacaoMovimentacaoColumn];
    motivoMovimentacao = map[motivoMovimentacaoColumn];
    dataHoraMovimentacao = map[dataHoraMovimentacaoColumn];
    somadaConta = map[somadaContaColumn] == 0;
    somadaOrcamento = map[somadaOrcamentoColumn] == 0;
    idConta = map[idContaMovimentacaoColumn];
    idCartaoCredito = map[idCartaoCreditoMovimentacaoColumn];
    idCategoria = map[idCategoriaMovimentacaoColumn];
    idTransferencia = map[idMovimentacaoTransferenciaColumn];
    idOrcamento = map[idOrcamentoMovimentacaoColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      tipoMovimentacaoColumn: tipoMovimentacao,
      valorMovimentacaoColumn: valorMovimentacao,
      naturezaOperacaoMovimentacaoColumn: naturezaOperacaoMovimentacao,
      motivoMovimentacaoColumn: motivoMovimentacao,
      dataHoraMovimentacaoColumn: dataHoraMovimentacao,
      somadaContaColumn: somadaConta == true ? 1 : 0,
      somadaOrcamentoColumn: somadaOrcamento == true ? 1 : 0,
      idContaMovimentacaoColumn: idConta,
      idCartaoCreditoMovimentacaoColumn: idCartaoCredito,
      idCategoriaMovimentacaoColumn: idCategoria,
      idMovimentacaoTransferenciaColumn: idTransferencia,
      idOrcamentoMovimentacaoColumn : idOrcamento,
    };
    if(idMovimentacao != null){
      map[idMovimentacaoColumn] = idMovimentacao;
    }
    return map;
  }

  @override
  String toString() {
    return "movimentacaoTable(idMovimentacao: $idMovimentacao, tipoMovimentacao: $tipoMovimentacao, valorMovimentacao: $valorMovimentacao, naturezaOperacaoMovimentacao: $naturezaOperacaoMovimentacao, motivoMovimentacao: $motivoMovimentacao, dataHoraMovimentacao: $dataHoraMovimentacao, idConta: $idConta, idCategoria: $idCategoria, idTransferencia: $idTransferencia, idOrcamento: $idOrcamento, somaConta: $somadaConta, somaOrcamento: $somadaOrcamento)";
  }


}




