import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';
import 'package:tavolo_mobile/data/repositories/headquarter_repository.dart';

import '../../../conf/api_client.dart';
import '../../../data/models/tables/table_response.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../storage/secure_storage.dart';
import '../../../storage/table_storage.dart';
import 'package:http/http.dart' as http;

class DetailHeadquarterScreen extends StatefulWidget {
  final int headquarterId;
  final HeadquarterRepository repository;
  final HeadquarterResponse? headquarter; // Opcional: si ya tenemos los datos
  final TableRepository? tableRepository; // Añadir como opcional

  const DetailHeadquarterScreen({
    Key? key,
    required this.headquarterId,
    required this.repository,
    this.headquarter,
    this.tableRepository,
  }) : super(key: key);

  @override
  State<DetailHeadquarterScreen> createState() => _DetailHeadquarterScreenState();
}

class _DetailHeadquarterScreenState extends State<DetailHeadquarterScreen> {
  bool _isLoading = true;
  bool _isLoadingTables = true;
  HeadquarterResponse? _headquarter;
  List<TableResponse> _tables = [];
  String? _errorMessage;
  String? _tablesErrorMessage;
  late final TableRepository _tableRepository;


  @override
  void initState() {
    super.initState();

    // Inicializar el repositorio de mesas si no se proporciona
    _tableRepository = widget.tableRepository ?? TableRepository(
        apiClient: ApiClient(
          httpClient: http.Client(),
          secureStorage: SecureStorage(storage: FlutterSecureStorage()),
          baseUrl: 'http://10.0.2.2:8080',
        ),
        tableStorage: TableStorage(storage: FlutterSecureStorage())
    );

    // Si ya tenemos los datos de la sede, no necesitamos cargarlos
    if (widget.headquarter != null) {
      _headquarter = widget.headquarter;
      _isLoading = false;
      _loadTables();
    } else {
      _loadHeadquarterDetails();
    }
  }

  Future<void> _loadHeadquarterDetails() async {
    try {
      final data = await widget.repository.getHeadquarterByHeadquarterId(widget.headquarterId.toString());
      setState(() {
        _headquarter = HeadquarterResponse.fromJson(data);
        _isLoading = false;
      });
      _loadTables();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  Future<void> _loadTables() async {
    setState(() {
      _isLoadingTables = true;
      _tablesErrorMessage = null;
    });

    try {
      final data = await _tableRepository.getTablesByHeadquarterId(widget.headquarterId.toString());
      final tables = data.map((item) => TableResponse.fromJson(item)).toList();

      setState(() {
        _tables = tables;
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() {
        _tablesErrorMessage = e.toString();
        _isLoadingTables = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_headquarter?.name ?? 'Detalles de Sede'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildHeadquarterDetails(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHeadquarterDetails,
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  Widget _buildHeadquarterDetails() {
    if (_headquarter == null) {
      return const Center(child: Text('No se encontraron detalles de la sede'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información general
          _buildSectionTitle('Información General'),
          _buildInfoItem('Nombre', _headquarter!.name),
          _buildInfoItem('Dirección', _headquarter!.streetAddress),

          const SizedBox(height: 24),

          // Contacto
          _buildSectionTitle('Contacto'),
          _buildInfoItem('Teléfono fijo', _headquarter!.landlinePhone),
          _buildInfoItem('Teléfono móvil', _headquarter!.mobilePhone),

          const SizedBox(height: 24),

          // Horarios
          _buildSectionTitle('Horarios'),
          _buildInfoItem('Horario de apertura', _headquarter!.openingTime),
          _buildInfoItem('Horario de cierre', _headquarter!.closingTime),
          _buildInfoItem('Intervalo de citas', '${_headquarter!.intervalMinutes} minutos'),

          const SizedBox(height: 24),

          // Ubicación
          _buildSectionTitle('Ubicación'),
          _buildInfoItem('Latitud', _headquarter!.latitude.toString()),
          _buildInfoItem('Longitud', _headquarter!.longitude.toString()),

          // Aquí se podría agregar un mapa en el futuro
          const SizedBox(height: 16),
          const Text('Mapa disponible próximamente...'),

          const SizedBox(height: 32),

          // Sección para mesas
          const SizedBox(height: 32),
          _buildSectionTitle('Mesas Disponibles'),

          // Mostrar estado de carga o error de las mesas
          _isLoadingTables
              ? const Center(child: CircularProgressIndicator())
              : _tablesErrorMessage != null
              ? _buildTablesErrorView()
              : _buildTablesList(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTablesErrorView() {
    return Column(
      children: [
        Text('Error al cargar mesas: $_tablesErrorMessage',
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _loadTables,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _buildTablesList() {
    if (_tables.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('No hay mesas disponibles en esta sede')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _tables.length,
      itemBuilder: (context, index) {
        final table = _tables[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Aquí puedes navegar a la pantalla de detalles de mesa
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mesa ${table.tableNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${table.seats} asientos'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: table.status == 'AVAILABLE' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      table.status == 'AVAILABLE' ? 'Disponible' : 'Ocupada',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Zona: ${table.zone}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}