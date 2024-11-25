import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/datasources/api_client.dart';
import 'package:progetto_barcode/domain/repositories/product_repository.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/barcodeScannerPage.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';
import 'package:progetto_barcode/widget/ordersPage.dart'; // Importa il provider del magazzino

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ApiClient? apiClient;
  List<dynamic> stockData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  //  apiClient = ApiClient(Dio());
    _fetchStockData(0, ''); // Inizializza con id e reference vuoti
  }

  Future<void> _fetchStockData(int IDMagazzino, String Nome_Magazzino) async {
    try {
      // Usa il productRepositoryProvider per ottenere i dati
    final productRepository = ref.read(productRepositoryProvider);

      // Esegui la chiamata API tramite il repository
    final response = await productRepository.fetchGetStock(IDMagazzino, Nome_Magazzino);

   //   final response = await apiClient!.fetchGetStock(Id, Nome); //
     
      setState(() {
        stockData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore durante il caricamento: $e';
        isLoading = false;
      });
    }
  }

  List<Widget> _buildWarehouseButtons() {
  return stockData.map((stock) {
    final warehouseId = stock['IDMagazzino'];
    final reference = stock['Nome_Magazzino'] ?? 'N/A';
  
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: ElevatedButton(
          onPressed: () {
            // Aggiorna il warehouseId nel provider
            ref.read(warehouseIdProvider.notifier).state = warehouseId;

            // Naviga alla pagina di scansione
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaricaScaricaPage(warehouseId: warehouseId),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$reference',
                style: const TextStyle(fontSize: 24, ),
              ),
            ],
          ),
        ),
      ),
    );
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Magazzino'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(errorMessage)
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildWarehouseButtons(),
                      ),
                    ),
        ),
      ),
    );
  }
}
