// import 'package:progetto_barcode/data/datasources/api_client.dart';
// import '../../domain/repositories/product_repository.dart';

// class ProductRepositoryImpl implements ProductRepository {
//   final ApiClient apiClient;

//   ProductRepositoryImpl(this.apiClient);

//    @override
//   Future<List<Map<String, dynamic>>> fetchGetStock(int Id, String Nome) async {
//     // Chiama il metodo di ApiClient per ottenere la disponibilità del magazzino
//     final stockname= await apiClient.fetchGetStock(Id, Nome);
//     return stockname;
//   }
// }
import 'package:progetto_barcode/data/datasources/api_client.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/data/models/product_info_update.dart';
import 'package:progetto_barcode/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;

  // Costruttore che prende un ApiClient (può essere stub o reale)
  ProductRepositoryImpl(this.apiClient);

  // Metodo per il login
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await apiClient.login(username, password);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchGetStock() async {
    // Chiama il metodo di ApiClient per ottenere la disponibilità del magazzino
    final stockname = await apiClient.fetchGetStock();
    return stockname;
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IdMagazzino, int userId) async {
    final carica = await apiClient.fetchOrdiniCarica(IdMagazzino, userId);
    return carica;
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IdMagazzino, int userId) async{
    final scarica = await  apiClient.fetchOrdiniScarica(IdMagazzino, userId);
    return scarica;
  }
 
 Future<List<Map<String, dynamic>>> fetchMateriali(int IdMagazzino, int userId) async {
  final materiali = await apiClient.fetchMateriali(IdMagazzino, userId);
    return materiali;
  }

  @override
 Future<ProductInfo> getProductByBarcode(String barcode) async {
  final productData = await apiClient.getProductByBarcode( barcode,);
  print('Product data received: $productData'); // Aggiungi questo per debug
  return ProductInfo.fromJson(productData); // Converte la Map in un oggetto ProductInfo
}  

 @override
  Future<ProductInfoUpdate> updateProductCaricoQuantityOnServer(  String barcode, int userId, int newQuantity, int IDOrdine) 
  async {
    // Chiama il metodo di ApiClient per aggiornare la quantità del prodotto
    await apiClient.updateProductCaricoQuantityOnServer(barcode, userId, newQuantity, IDOrdine);
    return ProductInfoUpdate(barcode: barcode, userId: userId, newQuantity: newQuantity, IDOrdine: IDOrdine);
  }



 @override
  Future<ProductInfoUpdate> updateProductScaricoQuantityOnServer(  String barcode, int userId, int newQuantity, int IDOrdine) 
  async {
    // Chiama il metodo di ApiClient per aggiornare la quantità del prodotto
    await apiClient.updateProductScaricoQuantityOnServer(barcode, userId, newQuantity, IDOrdine);
    return ProductInfoUpdate(barcode: barcode, userId: userId, newQuantity: newQuantity, IDOrdine: IDOrdine);
  }

  Future<void> updateMaterialQuantityOnServer(String barcode,int newQuantity, int MaterialId, int UserId)async {
    await apiClient.updateMaterialQuantityOnServer(barcode, newQuantity, MaterialId, UserId);
  
  }
 }

//    // Implementazione del metodo per ottenere gli ordini di un magazzino
//   @override
//   Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId) async {
//     final orders = await apiClient.fetchOrdersByWarehouse(warehouseId);
//     return orders;
// }


 
