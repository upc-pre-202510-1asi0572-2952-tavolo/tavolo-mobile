class AvailabilitySlot {
  final String hour;
  final bool available;

  AvailabilitySlot({
    required this.hour,
    required this.available,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      hour: json['hour'],
      available: json['available']
    );
  }
}