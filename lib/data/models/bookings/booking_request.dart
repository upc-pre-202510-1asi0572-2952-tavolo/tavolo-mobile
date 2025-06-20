/*
  * {
  "clientId": 0,
  "tableId": 0,
  "bookingDate": "2025-06-20",
  "slotIds": [
    0
  ]
}* */
class BookingRequest {
  final int clientId;
  final int tableId;
  final String bookingDate;
  final List<int> slotIds;

  BookingRequest({
    required this.clientId,
    required this.tableId,
    required this.bookingDate,
    required this.slotIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'tableId': tableId,
      'bookingDate': bookingDate,
      'slotIds': slotIds,
    };
  }

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      clientId: json['clientId'] ?? 0,
      tableId: json['tableId'] ?? 0,
      bookingDate: json['bookingDate'] ?? '',
      slotIds: List<int>.from(json['slotIds'] ?? []),
    );
  }

}
