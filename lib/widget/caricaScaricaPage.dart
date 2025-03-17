import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/OrdiniCaricoPage.dart'; // Assicurati di importare OrdersPage
import 'package:progetto_barcode/widget/OrdiniScaricoPage.dart';
import 'package:progetto_barcode/widget/MaterialiPage.dart';

class CaricaScaricaPage extends ConsumerWidget {
  final int warehouseId; // ID del magazzino

  CaricaScaricaPage({required this.warehouseId, required int userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipologia di ordine'),
        centerTitle: true, // Centra il titolo dell'AppBar
        backgroundColor: Colors.teal, // Cambia il colore dell'AppBar
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.greenAccent],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bottone "Carica"
            _buildCustomButton(
              context,
              label: 'Carico',
              icon: Icons.file_upload_outlined,
              onPressed: () {
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
            ),
            const SizedBox(height: 30), // Spazio tra i bottoni

            // Bottone "Scarica"
            _buildCustomButton(
              context,
              label: 'Scarico',
              icon: Icons.file_download_outlined,
              onPressed: () {
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
            ),
            
            const SizedBox(height: 30), // Spazio tra i bottoni
            
            _buildCustomButton(
              context,
              label: 'Materiali',
              icon: Icons.inventory_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialiPage(
                      warehouseId: warehouseId,
                      userId: userId ?? 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Funzione helper per costruire un pulsante personalizzato
  Widget _buildCustomButton(BuildContext context,
      {required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, // Larghezza piena
      height: 100, // Altezza del bottone
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Arrotondamento dei bordi
          ),
          padding: const EdgeInsets.symmetric(vertical: 20), // Padding interno
          backgroundColor: Colors.white, // Colore di sfondo del pulsante
          shadowColor: Colors.black.withOpacity(0.2), // Colore dell'ombra
          elevation: 8, // Altezza dell'ombra
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 40,
          color: Colors.teal, // Colore dell'icona
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 24, // Dimensione del testo
            color: Colors.teal, // Colore del testo
          ),
        ),
      ),
    );
  }
}
