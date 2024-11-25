import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:progetto_barcode/data/datasources/ApiClientStub.dart';
import 'package:progetto_barcode/data/datasources/api_client.dart';
import 'package:progetto_barcode/domain/repositories/product_repository.dart';
import 'package:progetto_barcode/data/repositories/product_repository_impl.dart';


// final productRepositoryProvider = Provider<ProductRepository>((ref) {
//   // Crea un'istanza di ApiClient con Dio
//   final apiClient = ApiClient(Dio() );
//   return ProductRepositoryImpl(apiClient);
// });

// Define a StateProvider for storing the warehouseId
final warehouseIdProvider = StateProvider<int>((ref)=> 0);
//
// Define a StateProvider for storing the reference
final warehousereferenceProvider = StateProvider<String?>((ref) => null);
// 


// Provider per ApiClient (stub o reale)
final apiClientProvider = Provider<ApiClient>((ref) {
  bool useStub = false;  // Imposta a false per usare l'ApiClient reale

  if (useStub) {
    return ApiClientStub(); // Restituisce ApiClientStub se in modalità di test
  } else {
    return ApiClient(Dio()); // Restituisce ApiClient reale se in modalità di produzione
  }
});

// Provider per ProductRepository, che dipende da ApiClient
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProductRepositoryImpl(apiClient);  // Usa la corretta istanza di ApiClient



});
