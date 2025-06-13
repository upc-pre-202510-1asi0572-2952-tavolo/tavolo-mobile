/*
* ESTO ES EL BODY DEL HEADQUARTER
* {
  "name": "Main Branch",
  "landlinePhone": "+5112345678",
  "mobilePhone": "013152700",
  "latitude": -12.046373,
  "longitude": -77.042754,
  "street": "Av. Javier Prado",
  "number": "1234",
  "city": "Lima",
  "postalCode": "15023",
  "country": "Peru",
  "openingTime": "08:00",
  "closingTime": "18:30",
  "intervalMinutes": 30
}
* */

class HeadquarterRequest {

  final String name;
  final String landlinePhone;
  final String mobilePhone;
  final double latitude;
  final double longitude;
  final String street;
  final String number;
  final String city;
  final String postalCode;
  final String country;
  final String openingTime;
  final String closingTime;
  final int intervalMinutes;

  HeadquarterRequest({
    required this.name,
    required this.landlinePhone,
    required this.mobilePhone,
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.number,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.openingTime,
    required this.closingTime,
    required this.intervalMinutes,
  });

  factory HeadquarterRequest.fromJson(Map<String, dynamic> json) {
    return HeadquarterRequest(
      name: json['name'],
      landlinePhone: json['landlinePhone'],
      mobilePhone: json['mobilePhone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      street: json['street'],
      number: json['number'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      intervalMinutes: json['intervalMinutes'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'landlinePhone': landlinePhone,
      'mobilePhone': mobilePhone,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'number': number,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'intervalMinutes': intervalMinutes,
    };
  }
}