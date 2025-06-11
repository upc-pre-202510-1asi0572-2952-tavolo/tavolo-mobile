import 'dart:convert';
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/data/models/headquarters/headquarter.dart';
import 'package:tavolo_mobile/error/exceptions.dart';
import 'package:tavolo_mobile/storage/headquarter_storage.dart';

class HeadquarterRepository {
  final ApiClient apiClient;
  final HeadquarterStorage storage;

  HeadquarterRepository({
    required this.apiClient,
    required this.storage,
  });


}