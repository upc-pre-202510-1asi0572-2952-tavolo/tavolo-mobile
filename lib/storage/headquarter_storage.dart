import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HeadquarterStorage {
  final FlutterSecureStorage storage;

  HeadquarterStorage({required this.storage});

  // Guardar lista de sedes
  Future<void> saveHeadquarters(String headquartersJson) async {
    await storage.write(key: 'headquarters', value: headquartersJson);
  }

  // Obtener lista de sedes: /api/v1/headquarters
  Future<String?> getHeadquarters() async {
    return await storage.read(key: 'headquarters');
  }

  // Guardar una sede específica
  Future<void> saveHeadquarter(String headquarterId, String headquarterJson) async {
    await storage.write(key: 'headquarter_$headquarterId', value: headquarterJson);
  }

  // Obtener una sede específica
  Future<String?> getHeadquarter(String headquarterId) async {
    return await storage.read(key: 'headquarter_$headquarterId');
  }

  // Eliminar una sede específica
  Future<void> deleteHeadquarter(String headquarterId) async {
    await storage.delete(key: 'headquarter_$headquarterId');
  }
}