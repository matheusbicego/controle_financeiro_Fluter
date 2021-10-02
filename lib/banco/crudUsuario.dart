import 'dart:core';

final String usuarioTable = "usuarioTable";
final String idUsuarioColumn = "idUsuarioColumn";
final String nomeUsuarioColumn = "nomeUsuarioColumn";
final String senhaUsuarioColumn = "senhaUsuarioColumn";
final String salvaSenhaColumn = "salvaSenhaColumn";


class Usuario {

  int idUsuario;
  String nomeUsuario;
  String senhaUsuario;
  bool salvaSenha;

  Usuario();

  Usuario.fromMap(Map map){
    idUsuario = map[idUsuarioColumn];
    nomeUsuario = map[nomeUsuarioColumn];
    senhaUsuario = map[senhaUsuarioColumn];
    salvaSenha = map[salvaSenhaColumn] == 1;
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeUsuarioColumn: nomeUsuario.toString(),
      senhaUsuarioColumn: senhaUsuario.toString(),
      salvaSenhaColumn: salvaSenha == true ? 1 : 0,
    };
    if(idUsuario != null){
      map[idUsuarioColumn] = idUsuario;
    }
    return map;
  }

  @override
  String toString() {
    return "usuarioTable(idUsuario: $idUsuario, NomeUsuario: $nomeUsuario, senhaUsuario: $senhaUsuario)";
  }


}




