import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/OrdiniCaricoPage.dart';
import 'package:progetto_barcode/widget/OrdiniScaricoPage.dart';
import 'package:progetto_barcode/widget/MaterialiPage.dart';

class CaricaScaricaPage extends ConsumerWidget {
  final int warehouseId;
 

  CaricaScaricaPage({
    required this.warehouseId,
    required int userId,
   
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipologia di ordine'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        titleTextStyle: TextStyle(
          color: Colors.blueGrey[800],
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        iconTheme: IconThemeData(
          color: Colors.blueGrey[800],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            const SizedBox(height: 30),

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
                      // quantitaTotale: 0,
                      // quantitaRichiesta: 0,
                      // IdMateriale: 0,
                      // IdOrdine: 0,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Bottone "Materiali"
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

  }  // Funzione helper per costruire un pulsante personalizzato
  Widget _buildCustomButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Bordi arrotondati più evidenti
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 8, // Ombra sollevata per dare profondità
          shadowColor: Colors.black.withOpacity(0.2), // Ombra più chiara
          backgroundColor: Colors.blueGrey[100], // Colore di sfondo chiaro
          splashFactory: InkRipple.splashFactory, // Effetto al tocco
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 36,
          color: Colors.blueGrey[800], // Icona blu-grigio scuro
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold, // Testo più spesso
            color: Colors.blueGrey[800], // Colore del testo blu-grigio scuro
          ),
        ),
      ),
    );
  }
}
