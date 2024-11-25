import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/loginPage.dart'; // Importa la tua schermata di login

void main() {
  runApp(  ProviderScope(
      child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disabilita il banner "debug"
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema dell'app
      ),
      home: LoginPage(), // Imposta LoginPage come schermata principale
    );
  }
}
