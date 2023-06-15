import 'dart:convert';

LocationResponseModelClass locationResponseModelClassFromJson(String str) =>
    LocationResponseModelClass.fromJson(json.decode(str));

String locationResponseModelClassToJson(LocationResponseModelClass data) =>
    json.encode(data.toJson());

class LocationResponseModelClass {
  String latitude;
  String longitude;

  LocationResponseModelClass({
    required this.latitude,
    required this.longitude,
  });

  factory LocationResponseModelClass.fromJson(Map<String, dynamic> json) =>
      LocationResponseModelClass(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
