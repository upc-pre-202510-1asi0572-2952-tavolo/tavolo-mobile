/**
 * [
    {
    "id": 0,
    "name": "string",
    "landlinePhone": "string",
    "mobilePhone": "string",
    "latitude": 0,
    "longitude": 0,
    "streetAddress": "string",
    "openingTime": "string",
    "closingTime": "string",
    "intervalMinutes": 0
    }
    ]
 */

class HeadquarterResponse {

  final int id;

  final String name;
  final String landlinePhone;
  final String mobilePhone;
  final double latitude;
  final double longitude;
  final String streetAddress;
  final String openingTime;
  final String closingTime;
  final int intervalMinutes;



  HeadquarterResponse({
    required this.id,
    required this.name,
    required this.landlinePhone,
    required this.mobilePhone,
    required this.latitude,
    required this.longitude,
    required this.streetAddress,
    required this.openingTime,
    required this.closingTime,
    required this.intervalMinutes,
  });

  factory HeadquarterResponse.fromJson(Map<String, dynamic> json) {
    return HeadquarterResponse(
      id: json['id'],
      name: json['name'],
      landlinePhone: json['landlinePhone'],
      mobilePhone: json['mobilePhone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      streetAddress: json['streetAddress'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      intervalMinutes: json['intervalMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'landlinePhone': landlinePhone,
      'mobilePhone': mobilePhone,
      'latitude': latitude,
      'longitude': longitude,
      'streetAddress': streetAddress,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'intervalMinutes': intervalMinutes,
    };
  }
}