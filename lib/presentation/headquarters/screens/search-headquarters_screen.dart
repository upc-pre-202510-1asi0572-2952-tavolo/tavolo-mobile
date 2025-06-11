import 'package:flutter/material.dart';

class SearchHeadquartersScreen extends StatelessWidget {
  const SearchHeadquartersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Sedes'),
      ),
      body: Center(
        child: Text(
          'Pantalla de búsqueda de sedes'
        ),
      ),
    );
  }
}