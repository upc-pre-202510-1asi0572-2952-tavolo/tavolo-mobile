import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//Esta clase es un ejemplo de almacenamiento seguro para las sedes de la aplicación Tavolo Mobile.
class HeadquarterStorage {
  final FlutterSecureStorage storage;

  HeadquarterStorage({required this.storage});

  // Guardar todas las sedes
  Future<void> saveHeadquarters(String headquartersJson) async {
    await storage.write(key: 'headquarters', value: headquartersJson);
  }

  // Obtener todas las sedes
  Future<String?> getHeadquarters() async {
    return await storage.read(key: 'headquarters');
  }

  // Guardar una sede específica por su ID
  Future<void> saveHeadquarter(String headquarterId, String headquarterJson) async {
    await storage.write(key: 'headquarter_$headquarterId', value: headquarterJson);
  }

  // Obtener una sede específica por su ID
  Future<String?> getHeadquarter(String headquarterId) async {
    return await storage.read(key: 'headquarter_$headquarterId');
  }

}