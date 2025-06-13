import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter_response.dart';

class MapScreen extends StatefulWidget {
  final HeadquarterResponse headquarter;

  const MapScreen({Key? key, required this.headquarter}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();
  static const String mapboxAccessToken = 'pk.eyJ1IjoiYmFyYmFyYTE1IiwiYSI6ImNtYnNkY2U3ZDBtNTcydnBsaXpndzFyZ2UifQ.aqqvYRga2_IKRs3chVl_wQ';
  bool _isMapError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final LatLng headquarterLocation = LatLng(
      widget.headquarter.latitude,
      widget.headquarter.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B5A3C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubicación: ${widget.headquarter.name}',
          style: const TextStyle(
            color: Color(0xFF8B5A3C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isMapError
                ? _buildMapErrorView()
                : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: headquarterLocation,
                initialZoom: 15.0,
                onMapEvent: (event) {
                  if (event is MapEventMoveStart) {
                    setState(() {
                      _isMapError = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken',
                  additionalOptions: const {
                    'accessToken': mapboxAccessToken,
                    'id': 'mapbox.streets',
                  },
                  tileProvider: NetworkTileProvider(),
                  errorImage: const AssetImage('assets/map_placeholder.png'),
                  errorTileCallback: (tile, error, stackTrace) {
                    setState(() {
                      _isMapError = true;
                      _errorMessage = error.toString();
                    });
                    print('Error cargando mapa: $error');
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: headquarterLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF8B5A3C),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Panel de información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.headquarter.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.headquarter.streetAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMaps(
                        widget.headquarter.latitude,
                        widget.headquarter.longitude,
                        widget.headquarter.name,
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('Cómo llegar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5A3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapErrorView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_off,
              size: 64,
              color: Color(0xFF8B5A3C),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5A3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica tu conexión a Internet e intenta nuevamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isMapError = false;
                });
                mapController.move(
                  LatLng(widget.headquarter.latitude, widget.headquarter.longitude),
                  15.0,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5A3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps(double latitude, double longitude, String label) async {
    try {
      final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        final Uri geoUrl = Uri.parse('geo:$latitude,$longitude?q=$label');
        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl);
        } else {
          throw Exception('No se pudo abrir ninguna aplicación de mapas');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el mapa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}