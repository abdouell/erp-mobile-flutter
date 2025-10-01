class CheckoutRequest {
  final double? latitude;
  final double? longitude;
  final String checkoutType; // "ORDER" ou "NO_SALE"
  final String? motif;
  final String? note;
  final String? clientTimestamp;

  const CheckoutRequest({
    this.latitude,
    this.longitude,
    required this.checkoutType,
    this.motif,
    this.note,
    this.clientTimestamp,
  });

  // Factory pour checkout avec commande
  factory CheckoutRequest.withOrder({
    double? latitude,
    double? longitude,
  }) {
    return CheckoutRequest(
      latitude: latitude,
      longitude: longitude,
      checkoutType: 'ORDER',
    );
  }

  // Factory pour checkout sans vente
  factory CheckoutRequest.withoutSale({
    double? latitude,
    double? longitude,
    required String motif,
    String? note,
  }) {
    return CheckoutRequest(
      latitude: latitude,
      longitude: longitude,
      checkoutType: 'NO_SALE',
      motif: motif,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'checkoutType': checkoutType,
      'motif': motif,
      'note': note,
      'clientTimestamp': clientTimestamp,
    };
  }
}