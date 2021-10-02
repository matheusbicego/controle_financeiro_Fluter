import 'dart:core';

final String orcamentoTable = "orcamentoTable";
final String idOrcamentoColumn = "idOrcamentoColumn";
final String acumulaValorOrcamentoColumn = "acumulaValorOrcamentoColumn";
final String valorTotalOrcamentoColumn = "valorTotalOrcamentoColumn";
final String descricaoOrcamentoColumn = "descricaoOrcamentoColumn";
final String valorAtualOrcamentoColumn = "valorAtualOrcamentoColumn";
final String estorouLimiteOrcamentoColumn = "estorouLimiteOrcamentoColumn";
final String idCategoriaOrcamentoColumn = "idCategoriaOrcamentoColumn";
final String diasRenovacaoColumn = "diasRenovacaoColumn";
final String dataInicioOrcamentoColumn = "dataInicioOrcamentoColumn";
final String dataFimOrcamentoColumn = "dataFimOrcamentoColumn";
final String emUsoColumn = "expirouColumn";


class Orcamento{

  int idOrcamento;
  bool acumulaValorOrcamento;
  double valorTotalOrcamento;
  String descricaoOrcamento;
  double valorAtualOrcamento;
  bool estorouLimiteOrcamento;
  int diasRenovacao;
  String dataInicioOrcamento;
  String dataFimOrcamento;
  bool emUso;
  int idCategoria;

  Orcamento();

  Orcamento.fromMap(Map map){
    idOrcamento = map[idOrcamentoColumn];
    acumulaValorOrcamento = map[acumulaValorOrcamentoColumn] == 1;
    valorTotalOrcamento = map[valorTotalOrcamentoColumn];
    descricaoOrcamento = map[descricaoOrcamentoColumn];
    valorAtualOrcamento = map[valorAtualOrcamentoColumn];
    estorouLimiteOrcamento = map[estorouLimiteOrcamentoColumn] == 1;
    idCategoria = map[idCategoriaOrcamentoColumn];
    diasRenovacao = map[diasRenovacaoColumn];
    dataInicioOrcamento = map[dataInicioOrcamentoColumn];
    dataFimOrcamento = map[dataFimOrcamentoColumn];
    emUso = map[emUsoColumn] == 1;
  }

  Map toMap() {
    Map<String, dynamic> map = {
      acumulaValorOrcamentoColumn: acumulaValorOrcamento == true ? 1 : 0,
      valorTotalOrcamentoColumn: valorTotalOrcamento,
      descricaoOrcamentoColumn: descricaoOrcamento,
      valorAtualOrcamentoColumn: valorAtualOrcamento,
      estorouLimiteOrcamentoColumn: estorouLimiteOrcamento == true ? 1 : 0,
      idCategoriaOrcamentoColumn: idCategoria,
      diasRenovacaoColumn: diasRenovacao,
      dataInicioOrcamentoColumn: dataInicioOrcamento,
      dataFimOrcamentoColumn: dataFimOrcamento,
     emUsoColumn: emUso == true ? 1 : 0,
    };
    if(idOrcamento != null){
      map[idOrcamentoColumn] = idOrcamento;
    }
    return map;
  }

  @override
  String toString() {
    return "orcamentoTable(idOrcamento: $idOrcamento, acumulaValorOrcamento: $acumulaValorOrcamento, valorTotalOrcamento: $valorTotalOrcamento, descricaoOrcamento: $descricaoOrcamento, valorAtualOrcamento: $valorAtualOrcamento, estorouLimiteOrcamento: $estorouLimiteOrcamento, emUso: $emUso)";
  }
}




