class BookingData {
  static final BookingData _instance = BookingData._internal();
  factory BookingData() => _instance;
  BookingData._internal();

  final List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);

  void addBooking(Map<String, dynamic> booking) {
    _bookings.add(booking);
  }

  void clearBookings() {
    _bookings.clear();
  }
}
