import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/barcodeScannerPageScarico.dart';

class OrdiniScaricoPage extends ConsumerStatefulWidget {
  OrdiniScaricoPage({
    required this.warehouseId,
    required this.userId,
  });

  final int warehouseId; // ID del magazzino selezionato
  final int userId;

  @override
  _OrdiniScaricoPage createState() => _OrdiniScaricoPage();
}

class _OrdiniScaricoPage extends ConsumerState<OrdiniScaricoPage> {
  String? scannedBarcode;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';
  ProductInfo? productInfo;
  int totalQuantity = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrders(widget.warehouseId, widget.userId);
    _fetchPosizioniPerOrdini(orders);
  }


  Future<void> _fetchOrders(int warehouseId, int userId) async {
    try {
      final repository = ref.read(productRepositoryProvider);
      final fetchedOrders = await repository.fetchOrdiniScarica(warehouseId, userId);

      print('Ordini recuperati: $fetchedOrders'); // Debug per verificare il recupero degli ordini

      // Ora unisci le posizioni a ogni ordine
      await _fetchPosizioniPerOrdini(fetchedOrders);

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore durante il caricamento degli ordini: $e';
        isLoading = false;
      });
    }
  }


  
Future<void> _fetchPosizioniPerOrdini(List<Map<String, dynamic>> ordini) async {
  final repository = ref.read(productRepositoryProvider);

  for (var ordine in ordini) {
    try {  // Debug: Stampa i dettagli dell'ordine
      print("Ordine: ${ordine['IDOrdine']}");
      print("IDMateriale: ${ordine['IdMateriale']}");
      print("QuantitàTotale: ${ordine['QuantitàTotale']}");
      print("Posizione: ${ordine['posizione']}");

         final idMateriale = ordine['IdMateriale'];
          if (idMateriale == null) {
        print("IDMateriale è null per l'ordine ${ordine['IDOrdine']}");
        ordine['posizione'] = "Posizione non disponibile";
        continue; // Salta questo ordine
      }


      // Recupera la posizione dalla seconda chiamata API
      final posizioneResponse = await repository.fetchPosizioneMaterialiScarico(
        idMateriale, 
        widget.warehouseId, 
        widget.userId
      );

     // Debug per verificare la risposta
      print("Posizione risposta per IDMateriale ${ordine['IDMateriale']}: $posizioneResponse");

      // Assicurati che la risposta sia una lista e che non sia vuota
      if (posizioneResponse is List && posizioneResponse.isNotEmpty) {
        // Estrai la posizione dal primo elemento della lista
        final posizione = posizioneResponse[0]['posizione'];
        ordine['posizione'] = posizione ?? "Posizione non disponibile";
      } else {
        // Se la risposta è vuota o non è una lista, metti il valore di fallback
        ordine['posizione'] = "Posizione non disponibile";
      }
    } catch (e) {
      print("Errore nel recupero della posizione per l'ordine ${ordine['IDOrdine']}: $e");
      ordine['posizione'] = "Posizione non disponibile"; // Fallback in caso di errore
    }
  }
    print("Ordini con posizioni aggiornate: $ordini");

  // Aggiorna lo stato con gli ordini modificati
  setState(() {
    orders = ordini;
  });
}




 String? modifyScannedBarcode(String? barcode) {
    return barcode?.isNotEmpty == true ? barcode!.padLeft(13, '0') : barcode;
  }



  Future<void> _startBarcodeScan() async {
    setState(() => isLoading = true);

    try {
      print("Inizio scansione barcode...");
      final result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        print("Barcode scansionato: ${result.rawContent}");
        scannedBarcode = modifyScannedBarcode(result.rawContent);

        final ordini = orders.firstWhere(
          (m) => m['Barcode'] == scannedBarcode,
          orElse: () => <String, dynamic>{},
        );

        if (ordini.isNotEmpty) {
          print("Ordine trovato, navigazione verso BarcodeScannerPageScarico");
          ref.read(warehouseIdProvider.notifier).state = widget.warehouseId;
          
          print("Posizione passata: ${ordini['Posizione']}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScannerPageScarico(
                warehouseId: widget.warehouseId,
                userId: widget.userId,
                IdOrdine: ordini['IDOrdine'],
                quantitaTotale: ordini['QuantitàTotale'],
                quantitaRichiesta: ordini['Quantita_Richiesta'],
                barcode: scannedBarcode!,
               // posizione: ordini['posizione'],
                materialiId: int.tryParse(ordini['IdMateriale'].toString()) ?? 0,
              ),
            ),
          );
        } else {
          print("Ordine non trovato per il barcode scansionato.");
        }
      } else {
        print("Scansione fallita o barcode vuoto.");
      }
    } catch (e) {
      _showError('Errore durante la scansione: $e');
      print("Errore durante la scansione: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  void _showError(String message) {
    setState(() => errorMessage = message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _buildOrderList() {
   
    return orders.map((ordini) {
      final orderId = ordini['IDOrdine'];
      final orderName = ordini['Nome_Materiale'];
      final orderQuantityRequest = ordini['Quantita_Richiesta'];
      final orderQuantityTotal = ordini['QuantitàTotale'];
     // final orderPosition = ordini['posizione'];
      final orderBarcode = ordini['Barcode'];
      final orderIdMateriale = ordini['idMateriale'];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16.0),
              backgroundColor: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 6,
            ),
            onPressed: () {
              ref.read(warehouseIdProvider.notifier).state = widget.warehouseId;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerPageScarico(
                    warehouseId: widget.warehouseId,
                    userId: widget.userId,
                    IdOrdine: orderId,
                    quantitaTotale: orderQuantityTotal,
                    quantitaRichiesta: orderQuantityRequest,
                    barcode: orderBarcode,
                  //  posizione: orderPosition ,
                    materialiId: orderIdMateriale,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Ordine: $orderId',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nome prodotto: $orderName',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Quantità Richiesta: $orderQuantityRequest',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Quantità Totale: $orderQuantityTotal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                // Text(
                //   'Posizione: $orderPosition',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.white70,
                //   ),
                //),
                Text(
                  'Barcode: $orderBarcode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'ID Materiale: $orderIdMateriale',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
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
        title: const Text('Seleziona ordine di scarico'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(errorMessage)
                    : Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _startBarcodeScan,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Scansiona Barcode'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white70,
                              padding: const EdgeInsets.all(16.0),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ..._buildOrderList(),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
