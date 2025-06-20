/*
{
  "id": 0,
  "clientId": 0,
  "tableNumber": 0,
  "headquarterId": 0,
  "tableId": 0,
  "bookingDate": "2025-06-20",
  "bookingSlots": [
    {
      "startTime": "string",
      "endTime": "string"
    }
  ]
}
}* */
class BookingResponse {
  final int id;
  final int clientId;
  final int tableNumber;
  final int headquarterId;
  final int tableId;
  final String bookingDate;
  final String bookingSlots;

  BookingResponse({
    required this.id,
    required this.clientId,
    required this.tableNumber,
    required this.headquarterId,
    required this.tableId,
    required this.bookingDate,
    required this.bookingSlots,
  });
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] ?? 0,
      clientId: json['clientId'] ?? 0,
      tableNumber: json['tableNumber'] ?? 0,
      headquarterId: json['headquarterId'] ?? 0,
      tableId: json['tableId'] ?? 0,
      bookingDate: json['bookingDate'] ?? '',
      bookingSlots: json['bookingSlots'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'tableNumber': tableNumber,
      'headquarterId': headquarterId,
      'tableId': tableId,
      'bookingDate': bookingDate,
      'bookingSlots': bookingSlots,
    };
  }

}