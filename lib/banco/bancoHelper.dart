import 'dart:async';
import 'dart:core';
import 'package:controle_de_financas/banco/crudCategoria.dart';
import 'package:controle_de_financas/banco/crudCartaoCredito.dart';
import 'package:controle_de_financas/banco/crudMovimentacao.dart';
import 'package:controle_de_financas/banco/crudOrcamento.dart';
import 'package:controle_de_financas/banco/crudUsuario.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'crudConta.dart';


class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  static Database _db;

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "banco.db");
     return await openDatabase(path, version: 1, onConfigure: onConfigure,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $contaTable (
  $idContaColumn integer primary key autoincrement, 
  $nomeContaColumn text not null,
  $saldoContaColumn real,
  $idCorContaColumn integer not null,
  $dataContaColumn text DEFAULT (cast(strftime('YY/mm/dd HH: MM: SS') as text)),
  $limiteChequeEspecialContaColumn real
  )
''');
          await db.execute('''
create table $cartaoCreditoTable(
  $idCartaoCreditoColumn integer primary key autoincrement,
  $nomeCartaoCreditoColumn text not null,
  $dataInicioCartaoCreditoColumn text DEFAULT (cast(strftime('YY/mm/dd HH: MM: SS') as text)),
  $idContaCartaoCreditoColumn integer not null,
  FOREIGN KEY($idContaCartaoCreditoColumn) REFERENCES $contaTable($idContaColumn) ON DELETE NO ACTION ON UPDATE NO ACTION
  )          
 ''');
          await db.execute('''
create table $movimentacaoTable(
  $idMovimentacaoColumn integer primary key autoincrement,
  $tipoMovimentacaoColumn text,
  $valorMovimentacaoColumn real not null,
  $naturezaOperacaoMovimentacaoColumn text,
  $motivoMovimentacaoColumn text,
  $dataHoraMovimentacaoColumn text DEFAULT (cast(strftime('YY/mm/dd HH: MM: SS') as text)),
  $somadaContaColumn integer,
  $somadaOrcamentoColumn integer,
  $idContaMovimentacaoColumn integer not null,
  $idCartaoCreditoMovimentacaoColumn integer,
  $idCategoriaMovimentacaoColumn integer,
  $idOrcamentoMovimentacaoColumn integer,
  $idMovimentacaoTransferenciaColumn integer,
  FOREIGN KEY($idContaMovimentacaoColumn) REFERENCES $contaTable($idContaColumn) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY($idOrcamentoMovimentacaoColumn) REFERENCES $orcamentoTable($idOrcamentoColumn) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY($idCartaoCreditoMovimentacaoColumn) REFERENCES $cartaoCreditoTable($idCartaoCreditoColumn) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY($idCategoriaMovimentacaoColumn) REFERENCES $categoriaTable($idCategoriaColumn) ON DELETE NO ACTION ON UPDATE NO ACTION
  )
''');

          await db.execute('''
create table $categoriaTable(
  $idCategoriaColumn integer primary key autoincrement,
  $nomeCategoriaColumn text not null
  )
''');
          await db.execute('''
create table $orcamentoTable(
  $idOrcamentoColumn integer primary key autoincrement,
  $acumulaValorOrcamentoColumn integer not null,
  $valorTotalOrcamentoColumn real,
  $descricaoOrcamentoColumn text not null,
  $valorAtualOrcamentoColumn real,
  $estorouLimiteOrcamentoColumn integer,
  $diasRenovacaoColumn integer not null,
  $idCategoriaOrcamentoColumn integer not null,
  $dataInicioOrcamentoColumn text not null DEFAULT (cast(strftime('YY/mm/dd') as text)),
  $dataFimOrcamentoColumn text not null DEFAULT (cast(strftime('YY/mm/dd') as text)),
  $emUsoColumn integer,
  FOREIGN KEY($idCategoriaOrcamentoColumn) REFERENCES $categoriaTable($idCategoriaColumn) ON DELETE NO ACTION ON UPDATE NO ACTION
  )
''');

          await db.execute('''
create table $usuarioTable(
  $idUsuarioColumn integer primary key autoincrement,
  $nomeUsuarioColumn text,
  $senhaUsuarioColumn text,
  $salvaSenhaColumn int
  )
''');
          await db.execute('''
insert into $categoriaTable($idCategoriaColumn, $nomeCategoriaColumn)
values(1, "Despesas");
          ''');
          await db.execute('''
insert into $categoriaTable($idCategoriaColumn, $nomeCategoriaColumn)
values(2, "Lazer");
          ''');
          await db.execute('''
insert into $categoriaTable($idCategoriaColumn, $nomeCategoriaColumn)
values(3, "Recebimento");
          ''');
        });
  }

  Future<Conta> saveConta(Conta conta) async {
    Database banco = await db;
    conta.idConta = await banco.insert (contaTable, conta.toMap ());
    return conta;
  }

  Future<Conta> getConta(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (contaTable,
        columns: [
          idContaColumn,
          nomeContaColumn,
          saldoContaColumn,
          idCorContaColumn,
          dataContaColumn,
          limiteChequeEspecialContaColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Conta.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteConta(int id) async {
    Database banco = await db;
    return await banco.delete (
        contaTable, where: "$idContaColumn = ?", whereArgs: [id]);
  }

  Future<int> updateConta(Conta conta) async {
    Database banco = await db;
    return await banco.update (
        contaTable, conta.toMap (), where: "$idContaColumn = ?",
        whereArgs: [conta.idConta]);
  }

  Future<List> getAllConta() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $contaTable");
    List<Conta> listConta = List ();
    for (Map m in listMap) {
      listConta.add (Conta.fromMap (m));
    }
    return listConta;
  }

  Future<int> getNumberConta() async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $contaTable"));
  }

  Future<double> getSomaSaldoConta() async {
    Database banco = await db;
    var soma = await banco.rawQuery ("SELECT SUM($saldoContaColumn) FROM $contaTable");
    return soma[0]["SUM($saldoContaColumn)"];
  }

  Future<List> getContaMovimentacao(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $movimentacaoTable INNER JOIN $contaTable ON ($contaTable.idContaColumn = $movimentacaoTable.idContaMovimentacaoColumn) WHERE $contaTable.idContaColumn = $id");
    List<Movimentacao> listConta = List ();
    for (Map m in listMap) {
      listConta.add (Movimentacao.fromMap (m));
    }
    return listConta;
  }

  Future<CartaoCredito> saveCartaoCredito(CartaoCredito cartaoCredito) async {
    Database banco = await db;
    cartaoCredito.idCartaoCredito = await banco.insert (cartaoCreditoTable, cartaoCredito.toMap ());
    return cartaoCredito;
  }

  Future<CartaoCredito> getCartaoCredito(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (cartaoCreditoTable,
        columns: [
          idCartaoCreditoColumn,
          nomeCartaoCreditoColumn,
          dataInicioCartaoCreditoColumn,
          idContaCartaoCreditoColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return CartaoCredito.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteCartaoCredito(int id) async {
    Database banco = await db;
    return await banco.delete (
        cartaoCreditoTable, where: "$idCartaoCreditoColumn = ?", whereArgs: [id]);
  }

  Future<int> updateCartaoCredito(CartaoCredito cartaoCredito) async {
    Database banco = await db;
    return await banco.update (
        cartaoCreditoTable, cartaoCredito.toMap (), where: "$idCartaoCreditoColumn = ?",
        whereArgs: [cartaoCredito.idCartaoCredito]);
  }

  Future<List> getAllCartaoCredito() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $cartaoCreditoTable");
    List<CartaoCredito> listCartaoCredito = List ();
    for (Map m in listMap) {
      listCartaoCredito.add (CartaoCredito.fromMap (m));
    }
    return listCartaoCredito;
  }

  Future<List> getContaCartaoCredito(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $cartaoCreditoTable INNER JOIN $contaTable ON ($contaTable.idContaColumn = $cartaoCreditoTable.idContaCartaoCreditoColumn) WHERE $contaTable.idContaColumn = $id");
    List<CartaoCredito> listConta = List ();
    for (Map m in listMap) {
      listConta.add (CartaoCredito.fromMap (m));
    }
    return listConta;
  }

  Future<int> getNumberCartaoCredito() async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $cartaoCreditoTable"));
  }

  Future<Movimentacao> saveMovimentacao(Movimentacao movimentacao) async {
    Database banco = await db;
    movimentacao.idMovimentacao = await banco.insert (movimentacaoTable, movimentacao.toMap ());
    return movimentacao;
  }

  Future<Movimentacao> getMovimentacao(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (movimentacaoTable,
        columns: [
          idMovimentacaoColumn,
          tipoMovimentacaoColumn,
          valorMovimentacaoColumn,
          naturezaOperacaoMovimentacaoColumn,
          motivoMovimentacaoColumn,
          dataHoraMovimentacaoColumn,
          idContaMovimentacaoColumn,
          idOrcamentoMovimentacaoColumn,
          idCartaoCreditoMovimentacaoColumn,
          idCategoriaMovimentacaoColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Movimentacao.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteMovimentacao(int id) async {
    Database banco = await db;
    return await banco.delete (
        movimentacaoTable, where: "$idMovimentacaoColumn = ?", whereArgs: [id]);
  }

  Future<int> updateMovimentacao(Movimentacao movimentacao) async {
    Database banco = await db;
    return await banco.update (
        movimentacaoTable, movimentacao.toMap (), where: "$idMovimentacaoColumn = ?",
        whereArgs: [movimentacao.idMovimentacao]);
  }

  Future<List> getOrcamentoMovimentacao(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $movimentacaoTable  INNER JOIN $orcamentoTable ON ($orcamentoTable.idOrcamentoColumn = $movimentacaoTable.idOrcamentoMovimentacaoColumn) WHERE $orcamentoTable.idOrcamentoColumn = $id ORDER BY $movimentacaoTable.idMovimentacaoColumn DESC, $movimentacaoTable.idMovimentacaoColumn ASC");
    List<Movimentacao> listOrcamento = List ();
    for (Map m in listMap) {
      listOrcamento.add (Movimentacao.fromMap (m));
    }
    return listOrcamento;
  }

  Future<List> getAllMovimentacao() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $movimentacaoTable ORDER BY $movimentacaoTable.dataHoraMovimentacaoColumn DESC, $movimentacaoTable.dataHoraMovimentacaoColumn ASC");
    List<Movimentacao> listMovimentacao = List ();
    for (Map m in listMap) {
      listMovimentacao.add (Movimentacao.fromMap (m));
    }
    return listMovimentacao;
  }

  Future<int> getNumberMovimentacao() async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $movimentacaoTable"));
  }

  Future<int> getNumberMovimentacaoCartaoCredito(int id) async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $movimentacaoTable INNER JOIN $cartaoCreditoTable ON ($cartaoCreditoTable.idCartaoCreditoColumn = $movimentacaoTable.idCartaoCreditoMovimentacaoColumn) WHERE $cartaoCreditoTable.idCartaoCreditoColumn = $id"));
  }

  Future<List> getMovimentacaoConta() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $contaTable INNER JOIN $movimentacaoTable ON ($contaTable.idContaColumn = $movimentacaoTable.idContaMovimentacaoColumn)");
    List<Conta> listConta = List ();
    for (Map m in listMap) {
      listConta.add (Conta.fromMap (m));
    }
    return listConta;
  }

  Future<List> getCartaoCreditoMovimentacao(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $movimentacaoTable INNER JOIN $cartaoCreditoTable ON ($cartaoCreditoTable.idCartaoCreditoColumn = $movimentacaoTable.idCartaoCreditoMovimentacaoColumn) WHERE $cartaoCreditoTable.idCartaoCreditoColumn = $id");
    List<Movimentacao> listMovimentacao = List ();
    for (Map m in listMap) {
      listMovimentacao.add (Movimentacao.fromMap (m));
    }
    return listMovimentacao;
  }

  Future<Categoria> saveCategoria(Categoria categoria) async {
    Database banco = await db;
    categoria.idCategoria = await banco.insert (categoriaTable, categoria.toMap ());
    return categoria;
  }

  Future<Categoria> getCategoria(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (categoriaTable,
        columns: [
          idCategoriaColumn,
          nomeCategoriaColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Categoria.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteCategoria(int id) async {
    Database banco = await db;
    return await banco.delete (
        categoriaTable, where: "$idCategoriaColumn = ?", whereArgs: [id]);
  }

  Future<int> updateCategoria(Categoria categoria) async {
    Database banco = await db;
    return await banco.update (
        categoriaTable, categoria.toMap (), where: "$idCategoriaColumn = ?",
        whereArgs: [categoria.idCategoria]);
  }

  Future<List> getAllCategoria() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $categoriaTable");
    List<Categoria> listCategoria = List ();
    for (Map m in listMap) {
      listCategoria.add (Categoria.fromMap (m));
    }
    return listCategoria;
  }

  Future<List> getCategoriaMovimento() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $categoriaTable INNER JOIN $movimentacaoTable ON ($categoriaTable.idCategoriaColumn = $movimentacaoTable.idCategoriaMovimentacaoColumn)");
    List<Categoria> listCategoria = List ();
    for (Map m in listMap) {
      listCategoria.add (Categoria.fromMap (m));
    }
    return listCategoria;
  }

  Future<List> getCategoriaOrcamento(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $orcamentoTable INNER JOIN $categoriaTable ON ($orcamentoTable.idCategoriaOrcamentoColumn = $categoriaTable.idCategoriaColumn) WHERE $categoriaTable.idCategoriaColumn = $id");
    List<Orcamento> listOrcamento = List ();
    for (Map m in listMap) {
      listOrcamento.add (Orcamento.fromMap (m));
    }
    return listOrcamento;
  }

  Future<List> getAllCategoriaOrcamento() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $orcamentoTable INNER JOIN $categoriaTable ON ($orcamentoTable.idCategoriaOrcamentoColumn = $categoriaTable.idCategoriaColumn)");
    List<Orcamento> listOrcamento = List ();
    for (Map m in listMap) {
      listOrcamento.add (Orcamento.fromMap (m));
    }
    return listOrcamento;
  }

  Future<List> getAllMovimentacaoCartaoCredito() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $cartaoCreditoTable INNER JOIN $movimentacaoTable ON ($cartaoCreditoTable.idCartaoCreditoColumn = $movimentacaoTable.idCartaoCreditoMovimentacaoColumn)");
    List<CartaoCredito> listCartaoCredito = List ();
    for (Map m in listMap) {
      listCartaoCredito.add (CartaoCredito.fromMap (m));
    }
    return listCartaoCredito;
  }

  Future<List> getOrcamentoCategoria() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $categoriaTable INNER JOIN $orcamentoTable ON ($orcamentoTable.idCategoriaOrcamentoColumn = $categoriaTable.idCategoriaColumn)");
    List<Categoria> listCategoria = List ();
    for (Map m in listMap) {
      listCategoria.add (Categoria.fromMap (m));
    }
    return listCategoria;
  }

  Future<List> getOrcamentoCategoriaUnic(int id) async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $categoriaTable INNER JOIN $orcamentoTable ON ($orcamentoTable.idCategoriaOrcamentoColumn = $categoriaTable.idCategoriaColumn) WHERE $orcamentoTable.idCategoriaOrcamentoColumn = $id");
    List<Categoria> listCategoria = List ();
    for (Map m in listMap) {
      listCategoria.add (Categoria.fromMap (m));
    }
    return listCategoria;
  }

  Future<int> getNumberCategoria() async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $categoriaTable"));
  }

  Future<Orcamento> saveOrcamento(Orcamento orcamento) async {
    Database banco = await db;
    orcamento.idOrcamento = await banco.insert (orcamentoTable, orcamento.toMap ());
    return orcamento;
  }

  Future<Orcamento> getOrcamento(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (orcamentoTable,
        columns: [
          idOrcamentoColumn,
          acumulaValorOrcamentoColumn,
          valorTotalOrcamentoColumn,
          descricaoOrcamentoColumn,
          valorAtualOrcamentoColumn,
          estorouLimiteOrcamentoColumn,
          diasRenovacaoColumn,
          idCategoriaOrcamentoColumn,
          dataInicioOrcamentoColumn,
          dataFimOrcamentoColumn,
          emUsoColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Orcamento.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteOrcamento(int id) async {
    Database banco = await db;
    return await banco.delete (
        orcamentoTable, where: "$idOrcamentoColumn = ?", whereArgs: [id]);
  }

  Future<int> updateOrcamento(Orcamento orcamento) async {
    Database banco = await db;
    return await banco.update (
        orcamentoTable, orcamento.toMap (), where: "$idOrcamentoColumn = ?",
        whereArgs: [orcamento.idOrcamento]);
  }

  Future<List> getAllOrcamento() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $orcamentoTable");
    List<Orcamento> listOrcamento = List ();
    for (Map m in listMap) {
      listOrcamento.add (Orcamento.fromMap (m));
    }
    return listOrcamento;
  }

  Future<int> getNumberOrcamento() async {
    Database banco = await db;
    return Sqflite.firstIntValue (
        await banco.rawQuery ("SELECT COUNT(*) FROM $orcamentoTable"));
  }

  Future<double> getSomaGastoOrcamento() async {
    Database banco = await db;
    var soma = await banco.rawQuery ("SELECT SUM($valorAtualOrcamentoColumn) FROM $orcamentoTable");
    return soma[0]["SUM($valorAtualOrcamentoColumn)"];
  }

  Future<double> getSomaTotalOrcamento() async {
    Database banco = await db;
    var soma = await banco.rawQuery ("SELECT SUM($valorTotalOrcamentoColumn) FROM $orcamentoTable");
    return soma[0]["SUM($valorTotalOrcamentoColumn)"];
  }

  Future<Usuario> saveUsuario(Usuario usuario) async {
    Database banco = await db;
    usuario.idUsuario = await banco.insert (usuarioTable, usuario.toMap ());
    return usuario;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    Database banco = await db;
    return await banco.update (
        usuarioTable, usuario.toMap (), where: "$idUsuarioColumn = ?",
        whereArgs: [usuario.idUsuario]);
  }

  Future<Usuario> getUsuario(int id) async {
    Database banco = await db;
    List<Map> maps = await banco.query (usuarioTable,
        columns: [
          idUsuarioColumn,
          nomeUsuarioColumn,
          senhaUsuarioColumn,
          salvaSenhaColumn,
        ],
        where: "$id = ?",
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Usuario.fromMap (maps.first);
    } else {
      return null;
    }
  }

  Future<List> getAllUsuarios() async {
    Database banco = await db;
    List listMap = await banco.rawQuery ("SELECT * FROM $usuarioTable");
    List<Usuario> listUsuario = List ();
    for (Map m in listMap) {
      listUsuario.add (Usuario.fromMap (m));
    }
    return listUsuario;
  }

  Future<int> deleteUsuarios(int id) async {
    Database banco = await db;
    return await banco.delete (
        usuarioTable, where: "$idUsuarioColumn = ?", whereArgs: [id]);
  }

  Future close() async {
    Database banco = await db;
    await banco.close ();
  }
}

