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

import '../../map/map_screen.dart';
import 'reservation-modal_screen.dart';

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

  Future<void> _showReservationConfirmation(String tableTitle) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
              const SizedBox(width: 8),
              const Text(
                'Reserva confirmada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Has reservado $tableTitle en ${_headquarter?.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Horario: 19:00 - 21:00',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Ver mis reservas',
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () {
                // Navegar a la pantalla de reservas
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
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
          // Información
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Información:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(headquarter: _headquarter!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map, size: 16, color: Colors.white),
                      label: const Text('Ver en mapa',
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w500,
                        color: Colors.white) ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(10, 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, _headquarter!.streetAddress),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filtros - reducidos en altura
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildDropdown('Capacidad:', _selectedCapacity,
                    ['Select', '2', '4', '6', '8'], (value) {
                      setState(() {
                        _selectedCapacity = value!;
                        _applyFilters();
                      });
                    }),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('Zona:', _selectedZone,
                    ['Select', 'Terraza', 'Interior', 'VIP'], (value) {
                      setState(() {
                        _selectedZone = value!;
                        _applyFilters();
                      });
                    }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de mesas
          _isLoadingTables
              ? const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ))
              : _tablesErrorMessage != null
              ? _buildTablesErrorView()
              : _buildTablesList(),

          const SizedBox(height: 24),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              itemHeight: 48,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: item == 'Select' ? const Color(0xFF999999) : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTablesErrorView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFE57373),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se pudieron cargar las mesas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ocurrió un error inesperado. Por favor, intenta nuevamente.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTables,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesList() {
    if (_tables.isEmpty) {
      return _buildEmptyTablesMessage();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index];
          return Card(
            margin: EdgeInsets.zero,
            elevation: 3,
            color: const Color(0xFFF1ECE6), // Color crema para las cards
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mesa #${table.tableNumber}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Capacidad: ${table.seats} personas",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Zona: ${table.zone}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReservationModal(
                            tableId: table.id,
                            tableName: "Mesa #${table.tableNumber}",
                            capacity: table.seats,
                            zone: table.zone,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8
                        ),
                      ),
                      child: const Text(
                        "Reservar",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white, // Texto blanco para los botones
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCard(String title, String capacity, String zone, bool isAvailable) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5E9D9), // Color crema
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isAvailable ? primaryColor : textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Capacidad: $capacity',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Zona: $zone',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: isAvailable
                    ? () => _showReservationConfirmation(title)
                    : null,
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
                    color: Colors.white, // Texto blanco
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTablesMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.table_bar,
            size: 48,
            color: Color(0xFFCCB3A2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay mesas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCapacity != 'Select' || _selectedZone != 'Select'
                ? 'Prueba con otros filtros de búsqueda'
                : 'En este momento no hay mesas disponibles en esta sede',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}