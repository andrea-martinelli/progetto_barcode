import 'package:dio/dio.dart';
import 'package:progetto_barcode/data/datasources/api_client.dart';


class ApiClientStub extends ApiClient {
  ApiClientStub() : super(Dio()); // Puoi passare un Dio vuoto o non usarlo affatto


  // Metodo di login (stub)
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simula un ritardo per imitare una chiamata API
    await Future.delayed(Duration(seconds: 1));

    // Simulazione della risposta API
    if (email == 'user' && password == '123') {
      return {
        'success': true,
        'token': 'fake_jwt_token',
        'userId': 1,
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    }
  }

  
//  @override
//   Future<List<Map<String, dynamic>>> fetchGetStock(int Id, String Nome) async {
//     // Simuliamo una risposta API con dati finti
//     return Future.delayed(
//       Duration(seconds: 1), // Simuliamo un ritardo per rendere la cosa realistica
//       () => [
//         {'Id': Id + 1, 'Nome': 'Magazzino 1', },
//         {'Id': Id + 2 , 'Nome': 'Magazzino 2', },
//         {'Id': Id + 3 , 'Nome': 'Magazzino 3', },
//       ],
//     );
//   }

  // Future<Map<String, dynamic>> fetchCarica(String operazione) async{
  //   return Future.delayed(
  //     Duration(seconds: 1),
  //     () => 
  //       {'operazione' : operazione , },
  //       {'operazione' :, },
  //       {'operazione' : , },
  //   );
  // }

  // Future<Map<String, dynamic>> fetchScarica(String operazione) async{
  //   return Future.delayed(
  //     Duration(seconds: 1),
  //     () => 
  //       {operazione: 'Scarica 5'},
  //       {operazione: 'Scarica 2'},
        
      
  //   );
  // }

  @override
  Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId, ) async {
    // Dati finti per il magazzino 1
    if (warehouseId == 1) {
      return [
        {'orderId': 101, 'product': 'Prodotto A', 'operazione': 'Carica 10', 'barcode': '1234567898735' },
        {'orderId': 102, 'product': 'Prodotto B', 'operazione': 'Scarica 5', 'barcode': '123456789870'},
        
      ];
    }
    // Dati finti per il magazzino 2
    else if (warehouseId == 2) {
      return [
        {'orderId': 201, 'product': 'Prodotto C', 'operazione': 'Carica 2', 'barcode': '123456789876'},
        {'orderId': 202, 'product': 'Prodotto D', 'operazione': 'Scarica 7', 'barcode': '123456789871' }
      ];
    }

    else if (warehouseId == 3) {
      return [
        {'orderId': 241, 'product': 'Prodotto V', 'operazione': 'Carica 6', 'barcode': '123456789872'},
        {'orderId': 252, 'product': 'Prodotto T', 'operazione': 'Scarica 20', 'barcode': '123456789874' }
      ];
    }
    return [];
  }


    // Future<Map<String, dynamic>> getProductByBarcode(String barcode, int warehouseId, String reference, int qty) async {
    //   // Simulazione di un ritardo per imitare il comportamento di una chiamata API
    //   await Future.delayed(Duration(seconds: 1));

    //   // Simulazione della risposta API
    //   if (barcode == '1234567898735') {
    //     // Simulazione di un prodotto specifico basato sul codice a barre
    //     return {
    //       'reference': reference,
    //       'qty': qty,
    //       'label': 'Etichetta del Prodotto 1',
    //     };
    //   } 
    //   else if (barcode == '123456789870') {
    //     // Simulazione di un altro prodotto
    //     return {
    //       'reference': reference,
    //       'qty': qty,
    //       'label': 'Etichetta del Prodotto 2',
    //     };
    //   } else {
    //     // Barcode non trovato o non valido
    //     throw Exception('Prodotto non trovato per il barcode: $barcode');
    //   }
    // }
 
//   Future<String> updateProductQuantityOnServer(String barcode, int qty, int warehouseId) async {
//   // Simulazione del comportamento della chiamata reale in base all'input
//   print('Simulazione invio richiesta con barcode: $barcode e qty: $qty per warehouseId: $warehouseId');

//   // Condizioni per simulare un comportamento simile a quello dell'API reale
//   if (warehouseId == 1) {
//     return Future.delayed(const Duration(seconds: 1), () {
//       return 'Quantità aggiornata con successo per il magazzino 1';
//     });
//   } else if (warehouseId == 2) {
//     return Future.delayed(const Duration(seconds: 1), () {
//       return 'Quantità aggiornata con successo per il magazzino 2';
//     });
//   } else {
//     return Future.delayed(const Duration(seconds: 1), () {
//       return 'Errore: Magazzino non trovato';
//     });
//   }
// }

}