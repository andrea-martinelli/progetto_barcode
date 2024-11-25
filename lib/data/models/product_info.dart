class ProductInfo {
  // final int id; // Campo richiesto
  final int Id;
  final String Nome; // Quantità, può essere negativa
  final int Giacenza;
  
  ProductInfo({
  //  required this.id,
     required this.Id,
    required this.Nome,
    required this.Giacenza,
   });

  // Metodo per aggiornare i campi con copyWith
  ProductInfo copyWith({  
   // int? id,
    int? Id,
    String? Nome,
    int? Giacenza,
     }) {
    return ProductInfo(
    //  id: id ?? this.id,
      Id: Id ?? this.Id,
      Nome: Nome ?? this.Nome,
      Giacenza: Giacenza ?? this.Giacenza,
     );
  }

  // Funzione per deserializzare un oggetto JSON
  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
    //   id: json['id'] ?? 0,
      Id: json['Id'] ?? '',
      Nome: json['Nome'] ?? 0,
      Giacenza: json['Giacenza'] ?? '', 
    );
  }

  // Funzione per serializzare un oggetto in JSON
  Map<String, dynamic> toJson() {
    return {
    //  'id': id,
      'Id': Id,
      'Nome': Nome,
      'Giacenza' : Giacenza,
     };
  }
}
