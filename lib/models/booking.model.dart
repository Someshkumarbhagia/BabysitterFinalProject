import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String id;
  String parentID;
  String babysitterID;
  String parentName;
  String babyName;
  String babyAge;
  String address;
  double lat;
  double driverLat;
  double lon;
  double driverLon;
  String status;
  String perHourCost;
  Timestamp serviceStartTime;
  Timestamp serviceEndTime;

  Booking({
    required this.id,
    required this.parentID,
    required this.babysitterID,
    required this.parentName,
    required this.babyName,
    required this.babyAge,
    required this.address,
    required this.lat,
    required this.driverLat,
    required this.lon,
    required this.driverLon,
    required this.status,
    required this.perHourCost,
    required this.serviceStartTime,
    required this.serviceEndTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      parentID: json['parentID'],
      babysitterID: json['babysitterID'],
      parentName: json['parentName'],
      babyName: json['babyName'],
      babyAge: json['babyAge'],
      address: json['address'],
      lat: json['lat'],
      driverLat: json['driverLat'],
      lon: json['lon'],
      driverLon: json['driverLon'],
      status: json['status'],
      perHourCost: json['perHourCost'],
      serviceStartTime: json['serviceStartTime'],
      serviceEndTime: json['serviceEndTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "parentID": this.parentID,
      "babysitterID": this.babysitterID,
      "parentName": this.parentName,
      "babyName": this.babyName,
      "babyAge": this.babyAge,
      "address": this.address,
      "lat": this.lat,
      "driverLat": this.driverLat,
      "lon": this.lon,
      "driverLon": this.driverLon,
      "status": this.status,
      "perHourCost": this.perHourCost,
      "serviceStartTime": this.serviceStartTime,
      "serviceEndTime": this.serviceEndTime,
    };
  }
}
