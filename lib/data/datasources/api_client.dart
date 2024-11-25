import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
   int? userId;
   int? IDMagazzino;
 
  ApiClient(
    this.dio,
  );


     // Metodo di login (chiamata reale)
Future<Map<String, dynamic>> login(String username, String password) async {
    final url = 'http://10.11.11.157:5158/api/Login/login'; // L'endpoint reale

    try {
      final response = await dio.post(
        url,
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Verifica se la risposta ha successo (status 200)
      if (response.statusCode == 200) {
        return {
          'success': true,
          'userId': response.data['userId'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] //?? 'Errore durante il login',
        };
      }
    } on DioException catch (e) {
      // Gestione di errori specifici di Dio
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Errore di connessione',
      };
    // } catch (e) {
    //   // Gestione di altri tipi di errori
    //   return {
    //     'success': false,
    //     'message': 'Errore durante il login: $e',
    //   };
    }
  }


     Future<List<Map<String, dynamic>>> fetchGetStock(int IDMagazzino, String Nome_Magazzino) async {
    final url = 'http://10.11.11.157:5158/api/Magazzino/GetMagazzino';

    try {
      final response = await dio.get(
        url,
        data: {
          'IDMagazzino': IDMagazzino,
          'Nome_Magazzino': Nome_Magazzino,
        },
        options: Options()
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Errore nella richiesta API: $e');
    }
  } 


   Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione) async {

       final url = 'http://10.11.11.157:5158/api/Ordini/GetOrdiniPerMagazzinoCarico?$IDMagazzino=$IDMagazzino&$userId=$userId';
    
      try {
      final response = await dio.get(
        url,
        data: {
          'IDOrdine': IDOrdine,
          'Nome_Materiale': Nome_Materiale,
          'Quantita_Richiesta': Quantita_Richiesta,
          'Posizione': Posizione,
        },
        options: Options()
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Errore nella richiesta API: $e');
    }
      
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IDOrdine, String Nome_Materiale, int Quantita_Richiesta, String Posizione) async {
    final url = 'http://10.11.11.157:5158/api/Ordini/GetOrdiniPerMagazzinoScarico?$IDMagazzino=$IDMagazzino&$userId=$userId';
   
    try {
      final response = await dio.get(
        url,
        data: {
          'IDOrdine': IDOrdine,
          'Nome_Materiale': Nome_Materiale,
          'Quantita_Richiesta': Quantita_Richiesta,
          'Posizione': Posizione,
        },
        options: Options()
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Errore nella richiesta API: $e');
    }
  }
  // Future<List<Map<String, dynamic>>> fetchOrdersByWarehouse(int warehouseId) async {
  //   final String url = 'https://api.example.com/orders'; // Cambia con il tuo URL reale

  //   try {
  //     final response = await dio.get(
  //       url,
  //       queryParameters: {
  //         'warehouseId': warehouseId, // Passa l'ID del magazzino come parametro
  //       },
  //     );

  //     // Assumi che la risposta dell'API sia una lista di ordini in formato JSON
  //     return List<Map<String, dynamic>>.from(response.data);
  //   } catch (e) {
  //     throw Exception('Errore nella richiesta API: $e');
  //   }
  //}


  Future<Map<String, dynamic>> getProductByBarcode(String barcode) async {
  final url = 'http://10.11.11.157:5158/api/Barcode/$barcode';

  try {
    print('Invio richiesta a: $url'); // Log dell'URL
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      return response.data; // Restituisci i dati come mappa
    } else {
      throw Exception('Errore nella risposta del server');
    }
  } catch (e) {
    throw Exception('Errore nella richiesta API: $e');
  }
}

  

// Metodo per aggiornare la quantità del prodotto sul server
  Future<String> updateProductQuantityOnServer(String barcode, int qty, int warehouseId) async {
    final url =
        'http://10.11.11.104:6003/api/ProductStock/adjust'; // Usa il nuovo endpoint
 
    try {
      print('Invio richiesta a $url con barcode: $barcode e qty: $qty');
      final response = await dio.put(
        url,
        data: {
          'barcode': barcode,
          'qty': qty,
          'warehouseId': warehouseId,
        },
      );
 
      print('Risposta dal server: ${response.data}');
 
      if (response.statusCode == 200) {
        return 'Quantità aggiornata con successo'; // Ritorna un messaggio di successo
      } else {
        throw Exception(
            'Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nella richiesta API: $e');
      throw Exception('Errore nella richiesta API: $e');
    }
  }
 

  
}

