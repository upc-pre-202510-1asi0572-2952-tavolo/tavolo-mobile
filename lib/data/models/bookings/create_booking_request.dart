class CreateBookingRequest {
  final int tableId;
  final String date;
  final String hour;

  CreateBookingRequest({
    required this.tableId,
    required this.date,
    required this.hour,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'date': date,
      'hour': hour,
    };
  }
}