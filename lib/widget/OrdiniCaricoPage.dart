import 'package:progetto_barcode/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/barcodeScannerPageCarico.dart';

class OrdiniCaricoPage extends ConsumerStatefulWidget {
  final int warehouseId; // ID del magazzino selezionato
  final int userId;

  OrdiniCaricoPage({required this.warehouseId, required this.userId});

  @override
  _OrdiniCaricoPage createState() => _OrdiniCaricoPage();
}

class _OrdiniCaricoPage extends ConsumerState<OrdiniCaricoPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders(widget.warehouseId, ref.read(userIdProvider)); // Chiamata API per recuperare gli ordini
  }

  Future<void> _fetchOrders(IdMagazzino, userId) async {
    try {
      // Recupera il repository dal provider
      final repository = ref.read(productRepositoryProvider);

      // Chiama il metodo fetchOrdersByWarehouse con l'ID del magazzino
      final fetchedOrders = await repository.fetchOrdiniCarica(IdMagazzino, userId);

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
    return orders.map ( (ordini) {
      final orderId = ordini['IDOrdine'];
      final orderName = ordini['Nome_Materiale'];
      final orderQuantity = ordini['Quantita_DiRientro'];
      final orderPosition = ordini['Posizione'];
      final orderBarcode = ordini['Barcode'];
      final idMateriale = ordini['IDMateriale'];

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
                  builder: (context) => BarcodeScannerPageCarico(
                    warehouseId: widget.warehouseId,
                    IdOrdine: orderId,
                    userId: widget.userId, 
                    quantitaDiRientro: orderQuantity,
                    orderPosition: orderPosition,
                    orderBarcode: orderBarcode,
                 //   IdMateriale: idMateriale
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
                    color: Colors.white, // Colore del testo bianco
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nome prodotto: $orderName',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Colore del testo più chiaro
                  ),
                ),
                Text(
                  'Quantità Richiesta: $orderQuantity',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Barcode: $orderBarcode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Posizione di rientro: $orderPosition',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona ordine di carico'),
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
}
