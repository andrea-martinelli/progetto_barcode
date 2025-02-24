import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';
import 'package:progetto_barcode/providers.dart'; // Importa il provider
import 'package:progetto_barcode/widget/loginPage.dart'; // Assicurati di importare LoginPage

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<dynamic> stockData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStockData(); // Inizializza con id e reference vuoti
  }

  Future<void> _fetchStockData() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);
      final response = await productRepository.fetchGetStock();

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
    final userId = ref.read(userIdProvider);

    return stockData.map((stock) {
      final warehouseId = stock['IDMagazzino'];
      final reference = stock['Nome_Magazzino'] ?? 'N/A';

      return Card(
        elevation: 6, // Aggiunge ombra alla Card
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), // Spaziatura tra le Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordi arrotondati
        ),
        child: InkWell(
          onTap: () {
            ref.read(warehouseIdProvider.notifier).state = warehouseId;

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => CaricaScaricaPage(
                  warehouseId: warehouseId,
                  userId: userId!,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warehouse, color: Colors.blueGrey), // Icona magazzino
                    const SizedBox(width: 8), // Spaziatura tra l'icona e il testo
                    Text(
                      '$reference',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800], // Colore del testo più scuro
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID Magazzino: $warehouseId',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Funzione per mostrare l'AlertDialog di conferma logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Logout'),
          content: const Text('Sei sicuro di voler uscire?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi la finestra di dialogo
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi la finestra di dialogo
                _logout(); // Esegui il logout
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  // Funzione per gestire il logout
  void _logout() {
    // Reset dello stato dell'utente
    ref.read(userIdProvider.notifier).state = null;

    // Naviga verso la pagina di login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Magazzino'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout, // Aggiungi l'AlertDialog qui
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(
                      errorMessage,
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    )
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
