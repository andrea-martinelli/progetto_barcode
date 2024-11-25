// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:progetto_barcode/widget/barcodeScannerPage.dart'; // Assicurati che il widget della scansione del barcode sia importato
// import 'package:progetto_barcode/providers.dart'; // Importa il provider

// class OrdersPage extends ConsumerStatefulWidget {
//   final int warehouseId; // ID del magazzino selezionato
//   OrdersPage({required this.warehouseId});

//   @override
//   _OrdersPageState createState() => _OrdersPageState();
// }

// class _OrdersPageState extends ConsumerState<OrdersPage> {
//   List<Map<String, dynamic>> orders = [];
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//    // _fetchOrders(); // Chiamata API per recuperare gli ordini
//   }

//   // Future<void> _fetchOrders() async {
//   //   try {
//   //     // Recupera il repository dal provider
//   //     final repository = ref.read(productRepositoryProvider);

//   //     // // Chiama il metodo fetchOrdersByWarehouse con l'ID del magazzino
//   //     // final fetchedOrders = await repository.fetchOrdersByWarehouse(widget.warehouseId);

//   //   //   setState(() {
//   //   //     orders = fetchedOrders;
//   //   //     isLoading = false;
//   //   //   });
//   //   // } catch (e) {
//   //   //   setState(() {
//   //   //     errorMessage = 'Errore durante il caricamento degli ordini: $e';
//   //   //     isLoading = false;
//   //   //   });
//   //   // }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ordini Magazzino ${widget.warehouseId}'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final order = orders[index];

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(double.infinity, 60), // Larghezza completa e altezza fissa
//                         ),
//                         onPressed: () {
//                           // Naviga alla pagina di scansione con l'ID dell'ordine
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BarcodeScannerPage(
//                                 orderId: order['orderId'], 
//                                 barcode: order['barcode']),
//                             ),
//                           );
//                         },
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'ID Ordine: ${order['orderId']}',
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 4), // Spazio tra ID e Prodotto
//                             Text(
//                               'Nome prodotto: ${order['product']} - Operazione: ${order['operazione']}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 4), // Spazio tra prodotto/quantità e stato
                            
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
