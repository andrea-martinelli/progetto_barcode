
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/data/models/product_info_update.dart';

abstract class ProductRepository {

   Future<Map<String, dynamic>> login(String username, String password);


  Future<List<Map<String, dynamic>>> fetchGetStock(int IDMagazzino, String Nome_Magazzino);  

    Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione);

    Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione);
 
  // Nuova funzione per ottenere gli ordini di un magazzino
 // Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId);

   Future<ProductInfo> getProductByBarcode(String barcode);

   Future<ProductInfoUpdate> updateProductQuantityOnServer(String barcode, int qty, int warehouseId); // Aggiungi questo metodo
    
}