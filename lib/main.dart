import 'package:flutter/material.dart';
import 'package:agenda_contatos/ui/home_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importação para desktop
import 'dart:io' show Platform; // Importação para detectar a plataforma

void main() {
  // Verifica se está no ambiente Desktop e inicializa o sqflite_common_ffi para ambientes desktop
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    sqfliteFfiInit(); // Inicializa a biblioteca sqflite_common_ffi para desktop
    databaseFactory = databaseFactoryFfi; // Define o databaseFactory como ffi
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}
