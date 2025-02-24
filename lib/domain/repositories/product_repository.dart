
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/data/models/product_info_update.dart';

abstract class ProductRepository {

   Future<Map<String, dynamic>> login(String username, String password);


  Future<List<Map<String, dynamic>>> fetchGetStock();  

    Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IdMagazzino, int userId);

    Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IdMagazzino, int userId);
 
  // Nuova funzione per ottenere gli ordini di un magazzino
 // Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId);

   Future<ProductInfo> getProductByBarcode(String barcode);

   Future<ProductInfoUpdate> updateProductCaricoQuantityOnServer( String barcode, int userId, int newQuantity, int IDOrdine); // Aggiungi questo metodo

   Future<ProductInfoUpdate> updateProductScaricoQuantityOnServer( String barcode, int userId, int newQuantity, int IDOrdine); // Aggiungi questo metodo
    
}