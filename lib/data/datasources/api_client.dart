import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
   int? userId;
   int? idMagazzino;
 
  ApiClient(
    this.dio,
  );


     // Metodo di login (chiamata reale)
Future<Map<String, dynamic>> login(String username, String password) async {
    final url = 'https://bc7a-151-53-251-220.ngrok-free.app/api/Login/login';
   // 'http://10.11.11.157:5158/api/Login/login;' // L'endpoint reale

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
        'message': e.response?.data['message'],
      };
    // } catch (e) {
    //   // Gestione di altri tipi di errori
    //   return {
    //     'success': false,
    //     'message': 'Errore durante il login: $e',
    //   };
    }
  }


     Future<List<Map<String, dynamic>>> fetchGetStock() async {
    final url = 'https://bc7a-151-53-251-220.ngrok-free.app/api/Magazzino/GetMagazzino';
    //'http://10.11.11.157:5158/api/Magazzino/GetMagazzino';

    try {
      final response = await dio.get(
        url,
        options: Options()
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Errore nella richiesta API: $e');
    }
  } 


   Future<List<Map<String, dynamic>>> fetchOrdiniCarica(int idMagazzino, int userId) async {

       final url = 'https://bc7a-151-53-251-220.ngrok-free.app/api/Ordini/GetOrdiniPerMagazzinoCarico?idMagazzino=$idMagazzino&userId=$userId'; 
      // 'http://10.11.11.157:5158/api/Ordini/GetOrdiniPerMagazzinoCarico?idMagazzino=$idMagazzino&userId=$userId';

      try {
      final response = await dio.get(   
        url,
        options: Options()
      );
     if (response.statusCode == 200) {
      // Se la risposta è OK (200), restituiamo i dati
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      // Se non è 200, gestiamo l'errore
      final errorData = response.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
        // Se il messaggio di errore è presente nella risposta del server
        throw Exception('Errore dal server: ${errorData['message']}');
      } else {
        throw Exception('Errore nella risposta: codice ${response.statusCode}');
      }
    }
  } catch (e) {
    throw Exception('Errore nella richiesta API: $e');
  }
      
  }

  Future<List<Map<String, dynamic>>> fetchOrdiniScarica(int IdMagazzino, int userId) async {
    final url = 'https://bc7a-151-53-251-220.ngrok-free.app/api/Ordini/GetOrdiniPerMagazzinoScarico?idMagazzino=$IdMagazzino&userId=$userId';
    //'http://10.11.11.157:5158/api/Ordini/GetOrdiniPerMagazzinoScarico?idMagazzino=$IdMagazzino&userId=$userId';
   
    try {
      final response = await dio.get(
        url,
        options: Options()
      );
     if (response.statusCode == 200) {
      // Se la risposta è OK (200), restituiamo i dati
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      // Se non è 200, gestiamo l'errore
      final errorData = response.data;
      
      if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
        // Se il messaggio di errore è presente nella risposta del server
        throw Exception('Errore dal server: ${errorData['message']}');
      } else {
        throw Exception('Errore nella risposta: codice ${response.statusCode}');
      }
    }
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
  final url = 'https://bc7a-151-53-251-220.ngrok-free.app/api/Barcode/$barcode';
   //'http://10.11.11.157:5158/api/Barcode/$barcode';

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

  

// Metodo per aggiornare(carico) la quantità del prodotto sul server
 Future<void> updateProductCaricoQuantityOnServer(
  String barcode, int newQuantity, int IDOrdine,int UserID) async {
  
  // URL pulito
  final url = //'http://10.11.11.157:5158/api/Barcode/Carico/$barcode/$newQuantity/$IDOrdine/$UserID';
  'https://c544-151-53-251-220.ngrok-free.app/api/Barcode/Carico/$barcode/$newQuantity/$IDOrdine/$UserID';
  
  try {
    print('Invio richiesta PUT a $url con i seguenti parametri:');
    print('Barcode: $barcode, userId: $userId, newQuantity: $newQuantity, IDOrdine: $IDOrdine');
    
    // Invia i dati nel corpo della richiesta
    final response = await dio.put(
      url,
      data: {
        'barcode': barcode,
        'newQuantity': newQuantity,
        'IDOrdine': IDOrdine,
        'UserID': UserID,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Specifica che i dati sono in formato JSON
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Quantità aggiornata con successo.');
    } else {
      throw Exception('Errore nella risposta del server: ${response.statusCode}');
    }
  } catch (e) {
    print('Errore nella richiesta PUT: $e');
    throw Exception('Errore nella richiesta PUT: $e');
  }
}

 


// Metodo per aggiornare(carico) la quantità del prodotto sul server
 Future<void> updateProductScaricoQuantityOnServer(
  String barcode, int newQuantity, int IDOrdine,int UserID) async {
  
  // URL pulito
  final url = //'http://10.11.11.157:5158/api/Barcode/Scarico/$barcode/$newQuantity/$IDOrdine/$UserID';
  'https://bc7a-151-53-251-220.ngrok-free.app/api/Barcode/Scarico/$barcode/$newQuantity/$IDOrdine/$UserID';
  
  try {
    print('Invio richiesta PUT a $url con i seguenti parametri:');
    print('Barcode: $barcode, userId: $userId, newQuantity: $newQuantity, IDOrdine: $IDOrdine');
    
    // Invia i dati nel corpo della richiesta
    final response = await dio.put(
      url,
      data: {
        'barcode': barcode,
        'newQuantity': newQuantity,
        'IDOrdine': IDOrdine,
        'UserID': UserID,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Specifica che i dati sono in formato JSON
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Quantità aggiornata con successo.');
    } else {
      throw Exception('Errore nella risposta del server: ${response.statusCode}');
    }
  } catch (e) {
    print('Errore nella richiesta PUT: $e');
    throw Exception('Errore nella richiesta PUT: $e');
  }
}

  
}

