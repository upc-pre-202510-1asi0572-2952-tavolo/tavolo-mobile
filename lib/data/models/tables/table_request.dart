/*
* {
  "headquarterId": 0,
  "tableNumber": 0,
  "seats": 0,
  "zone": "string"
}
* */

class TableRequest {
  final int headquarterId;
  final int tableNumber;
  final int seats;
  final String status;
  final String zone;

  TableRequest({
    required this.headquarterId,
    required this.tableNumber,
    required this.seats,
    required this.status,
    required this.zone,
  });

  Map<String, dynamic> toJson() {
    return {
      'headquarterId': headquarterId,
      'tableNumber': tableNumber,
      'seats': seats,
      'status': status,
      'zone': zone,
    };
  }
}