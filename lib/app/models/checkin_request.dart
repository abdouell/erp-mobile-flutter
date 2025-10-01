
class CheckinRequest {
  final double? latitude;
  final double? longitude;
  final String? clientTimestamp;

  const CheckinRequest({
    this.latitude,
    this.longitude,
    this.clientTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'clientTimestamp': clientTimestamp,
    };
  }
}