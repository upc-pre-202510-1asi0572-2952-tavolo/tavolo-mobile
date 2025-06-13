/*
* {
  "id": 0,
  "headquarterId": 0,
  "tableNumber": 0,
  "seats": 0,
  "status": "string",
  "zone": "string"
}
* */

class TableResponse {
  final int id;
  final int headquarterId;
  final int tableNumber;
  final int seats;
  final String status;
  final String zone;

  TableResponse({
    required this.id,
    required this.headquarterId,
    required this.tableNumber,
    required this.seats,
    required this.status,
    required this.zone,
  });

  factory TableResponse.fromJson(Map<String, dynamic> json) {
    return TableResponse(
      id: json['id'],
      headquarterId: json['headquarterId'],
      tableNumber: json['tableNumber'],
      seats: json['seats'],
      status: json['status'],
      zone: json['zone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headquarterId': headquarterId,
      'tableNumber': tableNumber,
      'seats': seats,
      'status': status,
      'zone': zone,
    };
  }
}