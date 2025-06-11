import 'package:flutter/material.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';
import 'package:tavolo_mobile/data/repositories/headquarter_repository.dart';

import 'detail-headquarter_screen.dart';

class SearchHeadquartersScreen extends StatefulWidget {
  final HeadquarterRepository repository;

  const SearchHeadquartersScreen({
    super.key,
    required this.repository
  });

  @override
  State<SearchHeadquartersScreen> createState() => _SearchHeadquartersScreenState();
}


class _SearchHeadquartersScreenState extends State<SearchHeadquartersScreen> {
  List<HeadquarterResponse> _headquarters = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHeadquarters();
  }

  Future<void> _loadHeadquarters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await widget.repository.getHeadquarters();
      final headquarters = data
          .map((item) => HeadquarterResponse.fromJson(item))
          .toList();

      setState(() {
        _headquarters = headquarters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Sedes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildHeadquartersList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $_errorMessage',
              style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHeadquarters,
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  Widget _buildHeadquartersList() {
    if (_headquarters.isEmpty) {
      return const Center(child: Text('No hay sedes disponibles'));
    }

    return ListView.builder(
      itemCount: _headquarters.length,
      itemBuilder: (context, index) {
        final headquarter = _headquarters[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(headquarter.name),
            subtitle: Text(headquarter.streetAddress),
            trailing: Text('${headquarter.openingTime} - ${headquarter.closingTime}'),
            onTap: () {
              // Navegar al detalle de la sede
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailHeadquarterScreen(
                    headquarterId: headquarter.id,
                    repository: widget.repository,
                    headquarter: headquarter, // Pasamos los datos para evitar otra petición
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}