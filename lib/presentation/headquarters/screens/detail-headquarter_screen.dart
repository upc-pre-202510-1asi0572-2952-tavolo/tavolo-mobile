import 'package:flutter/material.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';
import 'package:tavolo_mobile/data/repositories/headquarter_repository.dart';

class DetailHeadquarterScreen extends StatefulWidget {
  final int headquarterId;
  final HeadquarterRepository repository;
  final HeadquarterResponse? headquarter; // Opcional: si ya tenemos los datos

  const DetailHeadquarterScreen({
    Key? key,
    required this.headquarterId,
    required this.repository,
    this.headquarter,
  }) : super(key: key);

  @override
  State<DetailHeadquarterScreen> createState() => _DetailHeadquarterScreenState();
}

class _DetailHeadquarterScreenState extends State<DetailHeadquarterScreen> {
  bool _isLoading = true;
  HeadquarterResponse? _headquarter;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Si ya tenemos los datos de la sede, no necesitamos cargarlos
    if (widget.headquarter != null) {
      _headquarter = widget.headquarter;
      _isLoading = false;
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

          // Botón para agendar cita
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de agendar cita
                // Navigator.pushNamed(context, '/appointment-booking', arguments: _headquarter!.id);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Agendar Cita'),
            ),
          ),
        ],
      ),
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