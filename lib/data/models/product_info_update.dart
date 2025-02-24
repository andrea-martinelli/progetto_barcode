class ProductInfoUpdate {
  final String barcode;
  final int userId;
  final int newQuantity;
  final int IDOrdine;
  
  ProductInfoUpdate({
    required this.barcode,
    required this.userId,  
    required this.newQuantity,
    required this.IDOrdine,
   });
    
    ProductInfoUpdate copyWith({
    String? barcode,
    int? userId,
    int? newQuantity,
    int? IDOrdine,
     })
      {

  return ProductInfoUpdate(
    barcode: barcode ?? this.barcode,
    userId: userId ?? this.userId,
    newQuantity: newQuantity ?? this.newQuantity, 
    IDOrdine: IDOrdine ?? this.IDOrdine,
     );
  }

 factory ProductInfoUpdate.fromJson(Map<String, dynamic> json) {
    return ProductInfoUpdate(
      barcode: json['barcode'] ?? '',
      userId: json['userId'] ?? 0,
      newQuantity: json['newQuantity'] ?? 0,
      IDOrdine: json['IDOrdine'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
       'barcode': barcode,
       'userId': userId,
       'newQuantity': newQuantity,
       'IDOrdine': IDOrdine,
      
    };
  }
}