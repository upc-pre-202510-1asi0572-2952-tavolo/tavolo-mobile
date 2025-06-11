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
  final HeadquarterResponse? headquarter;
  final TableRepository? tableRepository;

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
  String _selectedCapacity = 'Select';
  String _selectedZone = 'Select';

  static const Color primaryColor = Color(0xFF8B5A3C);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color cardColor = Colors.white;
  static const double cardBorderRadius = 12.0;

  List<TableResponse> _allTables = []; // Lista completa sin filtrar

  @override
  void initState() {
    super.initState();

    _tableRepository = widget.tableRepository ?? TableRepository(
        apiClient: ApiClient(
          httpClient: http.Client(),
          secureStorage: SecureStorage(storage: FlutterSecureStorage()),
          baseUrl: 'http://10.0.2.2:8080',
        ),
        tableStorage: TableStorage(storage: FlutterSecureStorage())
    );

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
        _allTables = tables; // Guardamos todas las mesas
        _applyFilters(); // Aplicamos los filtros iniciales
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() {
        _tablesErrorMessage = e.toString();
        _isLoadingTables = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _tables = _allTables.where((table) {
        // Si no hay filtros seleccionados, mostrar todas las mesas
        bool matchesCapacity = _selectedCapacity == 'Select' ||
            table.seats.toString() == _selectedCapacity;

        bool matchesZone = _selectedZone == 'Select' ||
            table.zone == _selectedZone;

        // La mesa debe coincidir con ambos filtros
        return matchesCapacity && matchesZone;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B5A3C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _headquarter?.name ?? 'Detalles de Sede',
          style: const TextStyle(
            color: Color(0xFF8B5A3C),
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
          : _buildHeadquarterDetails(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE0D5),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant,
            size: 48,
            color: primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            _headquarter?.name ?? "Sede Tavolo",
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A3C),
            ),
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
      child: Column(
        children: [
          _buildImagePlaceholder(),
          // Información de la sede
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on_outlined, _headquarter!.streetAddress),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time_outlined, '${_headquarter!.openingTime} - ${_headquarter!.closingTime}'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone_outlined, _headquarter!.landlinePhone),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filtros
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown('Capacidad:', _selectedCapacity, ['Select', '2', '4', '6', '8'], (value) {
                    setState(() {
                      _selectedCapacity = value!;
                    });
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown('Zona:', _selectedZone, ['Select', 'Terraza', 'Interior', 'VIP'], (value) {
                    setState(() {
                      _selectedZone = value!;
                    });
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lista de mesas
          _isLoadingTables
              ? const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5A3C)),
          ))
              : _tablesErrorMessage != null
              ? _buildTablesErrorView()
              : _buildTablesList(),

          const SizedBox(height: 100), // Espacio para el bottom nav
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF8B5A3C),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: item == 'Select' ? const Color(0xFF999999) : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                onChanged(newValue);
                // Aplicar filtros cuando cambia la selección
                _applyFilters();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTablesErrorView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text('Error al cargar mesas: $_tablesErrorMessage',
              style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadTables,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A3C),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesList() {
    if (_tables.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Center(child: Text('No hay mesas disponibles con los filtros seleccionados',
          style: TextStyle(fontSize: 16, color: textSecondaryColor),
        )),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5, // Aumenta este valor para hacer las tarjetas más pequeñas
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index];
          return _buildTableCard(
            'Mesa #${table.tableNumber}',
            '${table.seats} personas',
            table.zone,
            table.status == 'AVAILABLE',
          );
        },
      ),
    );
  }

  Widget _buildTableCard(String title, String capacity, String zone, bool isAvailable) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  capacity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  zone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: isAvailable ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Reservar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}