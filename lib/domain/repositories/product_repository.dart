
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/data/models/product_info_update.dart';

abstract class ProductRepository {

   Future<Map<String, dynamic>> login(String username, String password);

  Future<List<Map<String, dynamic>>> fetchGetStock();  

    Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IdMagazzino, int userId);

    Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IdMagazzino, int userId);
 
    Future<List<Map<String, dynamic>>> fetchMateriali(int IdMagazzino, int userId);

    Future<ProductInfo> getProductByBarcode(String barcode);

    Future<ProductInfoUpdate> updateProductCaricoQuantityOnServer( String barcode, int userId, int newQuantity, int IDOrdine); // Aggiungi questo metodo

    Future<ProductInfoUpdate> updateProductScaricoQuantityOnServer( String barcode, int userId, int newQuantity, int IDOrdine); // Aggiungi questo metodo

   Future<List<Map<String, dynamic>>> fetchPosizioneMateriali (int idMateriale, int idMagazzino, int userId);

   Future<List<Map<String, dynamic>>> fetchPosizioneMaterialiScarico(int idMateriale, int idMagazzino, int userId);

    Future<void> updateMaterialQuantityOnServer(String barcode,int newQuantity, int MaterialId, int UserId);

    
    
}