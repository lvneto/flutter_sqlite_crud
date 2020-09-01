class Contact {
  static const tblContact = 'contacts';
  static const colId = 'id';
  static const colPais = 'pais';
  static const colEstado = 'estado';
  static const colCidade = 'cidade';

  Contact({this.id, this.pais, this.estado, this.cidade});

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    pais = map[colPais];
    estado = map[colEstado];
    cidade = map[colCidade];
  }

  int id;
  String pais;
  String estado;
  String cidade;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colPais: pais,
      colEstado: estado,
      colCidade: cidade
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
