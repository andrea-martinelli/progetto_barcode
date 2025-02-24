import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/OrdiniCaricoPage.dart'; // Assicurati di importare OrdersPage
import 'package:progetto_barcode/widget/OrdiniScaricoPage.dart';

class CaricaScaricaPage extends ConsumerWidget {
  final int warehouseId; // ID del magazzino

  CaricaScaricaPage({required this.warehouseId, required int userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carica o Scarica'), // Titolo della pagina
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Margini intorno ai bottoni
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          children: [
            // Bottone "Carica"
            SizedBox(
              width: double.infinity, // Larghezza piena del bottone
              height: 300, // Altezza del bottone
              child: ElevatedButton(
                onPressed: () {
                  // Naviga a OrdersPage passando il warehouseId e l'azione "carica"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdiniCaricoPage(
                        warehouseId: warehouseId,
                        userId: userId ?? 0,
                     ),
                    ),
                  );
                },
                child: const Text(
                  'Carica',
                  style: TextStyle(fontSize: 24), // Testo grande
                ),
              ),
            ),
            const SizedBox(height: 30), // Spazio tra i bottoni
            // Bottone "Scarica"
            SizedBox(
              width: double.infinity, // Larghezza piena del bottone
              height: 300, // Altezza del bottone
              child: ElevatedButton(
                onPressed: () {
                  // Naviga a OrdersPage passando il warehouseId e l'azione "scarica"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdiniScaricoPage(
                        warehouseId: warehouseId,
                        userId: userId ?? 0,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Scarica',
                  style: TextStyle(fontSize: 24), // Testo grande
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}