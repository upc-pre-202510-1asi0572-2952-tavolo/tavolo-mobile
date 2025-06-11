import 'dart:convert';
import 'package:tavolo_mobile/conf/api_client.dart';

import '../../storage/headquarter_storage.dart';

// Esta clase se encarga de manejar las operaciones relacionadas con las sedes en la aplicación Tavolo Mobile.
class HeadquarterRepository {
  final ApiClient apiClient;
  final HeadquarterStorage headquarterStorage;

  HeadquarterRepository({
    required this.apiClient,
    required this.headquarterStorage,
  });

  // Métodos para manejar las sedes
  // Obtiene la lista de todas las sedes.
  Future<List<dynamic>> getHeadquarters() async {
    try {
      // La respuesta ya viene decodificada del apiClient
      final List<dynamic> headquarters = await apiClient.get('/api/v1/headquarters');

      // Guardar la lista de sedes en el almacenamiento
      await headquarterStorage.saveHeadquarters(json.encode(headquarters));

      return headquarters;
    } catch (e) {
      throw Exception('Error al obtener las sedes: $e');
    }
  }

  // Obtiene una sede específica por su ID.
  Future<dynamic> getHeadquarterByHeadquarterId(String headquarterId) async {
    try {
      final response = await apiClient.get('/api/v1/headquarters/$headquarterId');
      final headquarter = json.decode(response);

      // Guardar la sede específica en el almacenamiento
      await headquarterStorage.saveHeadquarter(headquarterId, json.encode(headquarter));

      return headquarter;
    } catch (e) {
      throw Exception('Error al obtener la sede: $e');
    }
  }



}