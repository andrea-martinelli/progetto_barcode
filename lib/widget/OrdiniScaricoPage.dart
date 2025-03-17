import 'package:progetto_barcode/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/barcodeScannerPageCarico.dart';
import 'package:progetto_barcode/widget/barcodeScannerPageScarico.dart';

class OrdiniScaricoPage extends ConsumerStatefulWidget {
  final int warehouseId; // ID del magazzino selezionato
  final int userId;

  OrdiniScaricoPage({required this.warehouseId, required this.userId});

  @override
  _OrdiniScaricoPage createState() => _OrdiniScaricoPage();
  
}

class _OrdiniScaricoPage extends ConsumerState<OrdiniScaricoPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders(widget.warehouseId, ref.read(userIdProvider) ); // Chiamata API per recuperare gli ordini
  }
   Future<void> _fetchOrders(IdMagazzino, userId) async {
    try {
      // Recupera il repository dal provider
      final repository = ref.read(productRepositoryProvider);

      // Chiama il metodo fetchOrdersByWarehouse con l'ID del magazzino
      final fetchedOrders = await repository.fetchOrdiniScarica(IdMagazzino, userId);

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


  List<Widget> _buildOrderList() {
    return orders.map((ordini) {
      final orderId = ordini['IDOrdine'];
      final orderName = ordini['Nome_Materiale'];
      final orderQuantityRequest = ordini['Quantita_Richiesta'];// da dover cambiare
      final orderQuantityTotal = ordini['QuantitàTotale'];
      final orderPosition = ordini['Posizione'];
      final orderBarcode = ordini['Barcode'];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16.0),
              backgroundColor: Colors.blueGrey[800], // Colore di sfondo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Bottone arrotondato
              ),
              elevation: 6, // Aggiungi ombra per un effetto moderno
            ),
            onPressed: () {
              // Aggiorna il warehouseId nel provider
              ref.read(warehouseIdProvider.notifier).state = widget.warehouseId;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerPageScarico(
                    warehouseId: widget.warehouseId,
                    userId: widget.userId,
                    IdOrdine: orderId,
                    quantitaTotale: orderQuantityTotal,
                    orderPosition: orderPosition,
                    quantitaRichiesta: orderQuantityRequest,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Ordine: $orderId',
                  style:const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Colore del testo bianco
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nome prodotto: $orderName',
                  style:const TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Colore del testo più chiaro
                  ),
                ),
                Text(
                  'Quantità Richiesta: $orderQuantityRequest',
                  style:const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Quantità Totale: $orderQuantityTotal',
                  style:const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Barcode: $orderBarcode',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Posizione: $orderPosition',
                  style:const TextStyle(
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
                        children: _buildOrderList(),
                      ),
                    ),
        ),
      ),
    );
  }



  //  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Ordini Magazzino ${widget.warehouseId}'),
  //     ),
  //     body: isLoading
  //         ? Center(child: CircularProgressIndicator())
  //         : errorMessage.isNotEmpty
  //             ? Center(child: Text(errorMessage))
  //             : ListView.builder(
  //                 itemCount: orders.length,
  //                 itemBuilder: (context, index) {
  //                   final order = orders[index];

  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //                     child: ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         minimumSize: Size(double.infinity, 60), // Larghezza completa e altezza fissa
  //                       ),
  //                       onPressed: () {
  //                         // Naviga alla pagina di scansione con l'ID dell'ordine
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => BarcodeScannerPage(
  //                               warehouseId: widget.warehouseId,
  //                               IdOrdine: order['IDOrdine'], 
  //                               userId: order['userID'],
  //                             )   
  //                           ),
  //                         );
  //                       },
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'ID Ordine: ${order['IDOrdine']}',
  //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                           ),
  //                           SizedBox(height: 4), // Spazio tra ID e Prodotto
  //                           Text(
  //                             'Nome prodotto: ${order['Nome_Materiale']} - Quantita_Richiesta: ${order['Quantita_Richiesta']}',
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                           Text(
  //                             'Posizione: ${order['Posizione']}',
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                           SizedBox(height: 4), // Spazio tra prodotto/quantità e stato
                            
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //   );
  // }
}