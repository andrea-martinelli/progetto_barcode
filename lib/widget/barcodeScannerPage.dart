import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/data/repositories/product_repository_impl.dart';
import 'package:progetto_barcode/data/datasources/api_client.dart';
import 'package:progetto_barcode/domain/repositories/product_repository.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key, required this.IdOrdine,});
  final int IdOrdine;


  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  String? scannedBarcode;
  ProductInfo? productInfo;
  int newQuantity = 0;
  bool isLoading = false;
  String? errorMessage;
  int totalQuantity = 0;
  //int? warehouseAvailability; // Variabile per la disponibilità
  String? reference;

  final TextEditingController _quantityController =
      TextEditingController(text: '0');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startBarcodeScan();
   // _loadWarehouseAvailability(); // Carica la disponibilità del magazzino all'avvio
  //  _loadWarehouseName(); // Carica il nome del magazzino all'avvio
  }


// Future<void> _loadWarehouseName() async {
//    if (reference == null || reference!.isEmpty) {
//     ref.read(warehousereferenceProvider.notifier).state = 'Nome del magazzino non disponibile';
//     return;
//   }
  
//   try {
//     final productRepository = ref.read(productRepositoryProvider);
//     final stockName = await productRepository.fetchGetStock(widget.IdOrdine, reference!);

//     if (stockName.isNotEmpty) {
//       final warehousename = stockName[0]['reference'] as String?;
//       if (warehousename != null) {
//         ref.read(warehousereferenceProvider.notifier).state = warehousename;
//       }
//     } else {
//       ref.read(warehousereferenceProvider.notifier).state = 'Nessun dato trovato';
//     }
//   } catch (e) {
//     ref.read(warehousereferenceProvider.notifier).state = 'Errore nel caricamento';
//   }
// }

  // Future<void> _loadWarehouseAvailability() async {
  //   try {
  //     final productRepository = ref.read(productRepositoryProvider);
  //     int availability = await productRepository.getDisponibilitaMagazzino(widget.warehouseId);
  //     setState(() {
  //       warehouseAvailability = availability;
  //     });
  //   } catch (e) {
  //     _showError('Errore nel recupero della disponibilità del magazzino: $e');
  //   }
  // }

 String? modifyScannedBarcode(String? barcode) {
  return barcode?.isNotEmpty == true  
      ? barcode!.padLeft(13, '0')
      : barcode;
}

  Future<void> _startBarcodeScan() async {
    setState(() => isLoading = true);

    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {

        // scannedBarcode = result.rawContent;
        scannedBarcode = modifyScannedBarcode(result.rawContent);

        print('Codice a barre scansionato: $scannedBarcode');
      
        // Recupera i dettagli del prodotto
        await _fetchProductDetails(scannedBarcode!);
      }
    } finally {
      setState(() => isLoading = false);
    }


  }

  Future<void> _fetchProductDetails(String barcode) async {
  try {
    setState(() => isLoading = true);

    // Recupera il repository dall'oggetto ref di Riverpod
    final productRepository = ref.read(productRepositoryProvider);

    // Effettua la chiamata API per ottenere i dettagli del prodotto
    final product = await productRepository.getProductByBarcode(barcode);

    // Aggiorna lo stato con i dettagli del prodotto
    setState(() {
      productInfo = ProductInfo(
        Id: product.Id,
        Nome: product.Nome,
        Giacenza: product.Giacenza,
      );
      totalQuantity = product.Giacenza;
      errorMessage = null;
    });
  } catch (e) {
    setState(() {
      errorMessage = 'Errore nel recupero dei dettagli del prodotto: $e';
    });
  } finally {
    setState(() => isLoading = false);
  }
}


  Future<void> _saveQuantity() async {
    if (scannedBarcode == null) return;

    setState(() => isLoading = true);

    final productRepository = ref.read(productRepositoryProvider);
    try {
      int quantityChange = int.tryParse(_quantityController.text) ?? 0;
      int newTotalQuantity = totalQuantity + quantityChange;

      // if (quantityChange > newTotalQuantity) {
      //   _showError('Errore: Quantità negativa non consentita.');
      //   return;
      // }

      await productRepository.updateProductQuantityOnServer(
          scannedBarcode!, quantityChange, );
      setState(() {
        totalQuantity = newTotalQuantity;
        _quantityController.text = '0';
      });

       // Aggiorna il provider della disponibilità del magazzino
  //  ref.invalidate(warehouseAvailabilityProvider(widget.Id));

      _showMessage('Quantità aggiornata con successo');

      // // Reimposta lo stato per ritornare alla schermata iniziale
      // scannedBarcode = null;
      // productInfo = null;
      // totalQuantity = 0;
    } catch (e) {
      _showError('Errore nell\'aggiornamento della quantità: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => errorMessage = message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Widget _buildWarehouseInfo() {
  //    final reference = ref.watch(referenceProvider); // Ottieni il valore dal provider
  //    if (reference == null || reference.isEmpty) {
  //   return const Text('Nessun magazzino trovato');
  // }

  //   return Column(
  //     children: [
  //       Text(
  //        'Nome Magazzino: $reference', // Usa il valore ottendere dal provider
  //         style: const TextStyle(fontSize: 18),
  //       ),
  //       const SizedBox(height: 16),
        
  //     ],
  //   );
  // }

  // Widget _buildScannerButton() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //      // if (warehouseAvailability != null)
  //         // Padding(
  //         //   padding: const EdgeInsets.only(bottom: 20),
  //         //   // child: Text(
  //         //   //   'Disponibilità magazzino: $warehouseAvailability',
  //         //   //   style: const TextStyle(fontSize: 24),
  //         //   // ),
  //         // ),
  //       SizedBox(
  //         height: 700,
  //         width: 450,
  //         child: ElevatedButton(
  //           onPressed: _startBarcodeScan,
  //           child: const Text('Inizia la scansione', style: TextStyle(fontSize: 20)),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildProductInfo() {
    return Column(
      children: [

     //    if (productInfo != null) _buildWarehouseInfo(),
         
       if (productInfo != null) ...[
        Text('Nome prodotto: ${productInfo!.Nome}',
            style: const TextStyle(fontSize: 26)),
        Text('Quantità attuale: $totalQuantity',
            style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 40),
        _buildQuantityInput(),
        const SizedBox(height: 20),
        _buildQuantityButtons(),
        const SizedBox(height: 30),
        SizedBox(
          width: 180,
          height: 100,
          child: ElevatedButton(
            onPressed: _saveQuantity,
            child: const Text('Salva', style: TextStyle(fontSize: 36)),
          ),
          ),
         const SizedBox(height: 30), // Spaziatura tra i bottoni
        // Nuovo pulsante per tornare alla schermata di scansione
        SizedBox(
          width: 180,
          height: 100,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                scannedBarcode = null;
                productInfo = null;
              });
              // // Torna indietro alla schermata di scansione
              // Navigator.pop(context); // Torna alla schermata precedente
            },
            child: const Text('Scansiona un altro prodotto', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
      ],
    );
  }

  Widget _buildQuantityInput() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nuova quantità',
          labelStyle: TextStyle(fontSize: 30),
        ),
        onChanged: (value) => setState(() {
          newQuantity = int.tryParse(value) ?? 0;
        }),
      ),
    );
  }

  Widget _buildQuantityButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIncrementButton('-', () {
          setState(() {
            newQuantity -= 1;
            _quantityController.text = newQuantity.toString();
          });
        }),
        const SizedBox(width: 30),
        _buildIncrementButton('+', () {
          setState(() {
            newQuantity += 1;
            _quantityController.text = newQuantity.toString();
          });
        }),
      ],
    );
  }

  Widget _buildIncrementButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                //  if (productInfo != null) _buildWarehouseInfo(),
               //   if (scannedBarcode == null) _buildScannerButton(),
                  if (scannedBarcode != null)
                    // Text(
                    //   'Codice a barre scansionato: $scannedBarcode',
                    //   style: const TextStyle(fontSize: 18),
                    // ),
                    
                  const SizedBox(height: 16),
                  if (productInfo != null) _buildProductInfo(),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

