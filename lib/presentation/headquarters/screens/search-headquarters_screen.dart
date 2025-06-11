import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';
import 'package:tavolo_mobile/data/repositories/headquarter_repository.dart';
import 'package:tavolo_mobile/data/repositories/table_repository.dart';

import '../../../conf/api_client.dart';
import '../../../data/models/tables/table_response.dart';
import '../../../storage/secure_storage.dart';
import '../../../storage/table_storage.dart';
import 'detail-headquarter_screen.dart';

import 'package:http/http.dart' as http;

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
  Map<int, List<TableResponse>> _headquarterTables = {};
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
    for (var headquarter in _headquarters) {
      await _loadTablesForHeadquarter(headquarter.id);
    }
  }

  Future<void> _loadTablesForHeadquarter(int headquarterId) async {
    try {
      // Crear una instancia de TableRepository independiente
      final tableRepository = TableRepository(
          apiClient: ApiClient(
            httpClient: http.Client(),
            secureStorage: SecureStorage(storage: FlutterSecureStorage()),
            baseUrl: 'http://10.0.2.2:8080',
          ),
          tableStorage: TableStorage(storage: FlutterSecureStorage())
      );

      final data = await tableRepository.getTablesByHeadquarterId(headquarterId.toString());
      _headquarterTables[headquarterId] = data.map((item) => TableResponse.fromJson(item)).toList();
      setState(() {});
    } catch (e) {
      print('Error al cargar mesas: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sedes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5A3C)),
      ))
          : _errorMessage != null
          ? _buildErrorView()
          : _buildHeadquartersList()
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A3C),
            ),
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
      padding: const EdgeInsets.all(16),
      itemCount: _headquarters.length,
      itemBuilder: (context, index) {
        final headquarter = _headquarters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailHeadquarterScreen(
                    headquarterId: headquarter.id,
                    repository: widget.repository,
                    headquarter: headquarter,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headquarter.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headquarter.closingTime != null
                        ? 'Horario: ${headquarter.openingTime} - ${headquarter.closingTime}'
                        : 'Horario: ${headquarter.openingTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headquarter.streetAddress != null
                        ? 'Dirección: ${headquarter.streetAddress}'
                        : 'Dirección no disponible',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mesas disponibles: ${_getAvailableTablesCount(headquarter)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _getAvailableTablesCount(HeadquarterResponse headquarter) {
    final tables = _headquarterTables[headquarter.id] ?? [];
    return tables.where((table) => table.status == 'AVAILABLE').length;
  }

}