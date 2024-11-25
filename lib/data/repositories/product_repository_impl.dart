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
  Future<List<Map<String, dynamic>>> fetchGetStock(int IDMagazzino, String Nome_Magazzino) async {
    // Chiama il metodo di ApiClient per ottenere la disponibilità del magazzino
    final stockname = await apiClient.fetchGetStock(IDMagazzino, Nome_Magazzino);
    return stockname;
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione) async {
    final carica = await apiClient.fetchOrdiniCarica(IDOrdine, Nome_Materiale, Quantita_Richiesta, Posizione);
    return carica;
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione) async{
    final scarica = await  apiClient.fetchOrdiniScarica(IDOrdine, Nome_Materiale, Quantita_Richiesta, Posizione);
    return scarica;
  }
 

//    // Implementazione del metodo per ottenere gli ordini di un magazzino
//   @override
//   Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId) async {
//     final orders = await apiClient.fetchOrdersByWarehouse(warehouseId);
//     return orders;
// }


 @override
 Future<ProductInfo> getProductByBarcode(String barcode) async {
  final productData = await apiClient.getProductByBarcode( barcode,);
  print('Product data received: $productData'); // Aggiungi questo per debug
  return ProductInfo.fromJson(productData); // Converte la Map in un oggetto ProductInfo
}  

 @override
  Future<ProductInfoUpdate> updateProductQuantityOnServer( String barcode, int qty, int warehouseId) 
  async {
    // Chiama il metodo di ApiClient per aggiornare la quantità del prodotto
    await apiClient.updateProductQuantityOnServer(barcode, qty, warehouseId);
    return ProductInfoUpdate(barcode: barcode, qty: qty, warehouseId: warehouseId);
  }

}