import 'dart:core';

final String categoriaTable = "categoriaTable";
final String idCategoriaColumn = "idCategoriaColumn";
final String nomeCategoriaColumn = "nomeNategoriaColumn";


class Categoria {

  int idCategoria;
  String nomeCategoria;



  Categoria();

  Categoria.fromMap(Map map){
    idCategoria = map[idCategoriaColumn];
    nomeCategoria = map[nomeCategoriaColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeCategoriaColumn: nomeCategoria,
    };
    if(idCategoria != null){
      map[idCategoriaColumn] = idCategoria;
    }
    return map;
  }

  @override
  String toString() {
    return "categoriaTable(idCategoria: $idCategoria, nomeCategoria: $nomeCategoria)";
  }


}




