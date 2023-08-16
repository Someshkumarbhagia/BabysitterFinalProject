class Request {
  String id;
  String babysitterName;
  String babysitterID;
  String parentID;
  String parentName;
  String babyName;
  String babyAge;
  double lat;
  double lon;
  String address;
  String status;
  String perHourCost;

  Request({
    required this.id,
    required this.babysitterName,
    required this.babysitterID,
    required this.parentID,
    required this.parentName,
    required this.babyName,
    required this.babyAge,
    required this.lat,
    required this.lon,
    required this.address,
    required this.status,
    required this.perHourCost,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      babysitterName: json['babysitterName'],
      babysitterID: json['babysitterID'],
      parentID: json['parentID'],
      parentName: json['parentName'],
      babyName: json['babyName'],
      babyAge: json['babyAge'],
      lat: json['lat'],
      lon: json['lon'],
      address: json['address'],
      status: json['status'],
      perHourCost: json['perHourCost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "babysitterName": this.babysitterName,
      "babysitterID": this.babysitterID,
      "parentID": this.parentID,
      "parentName": this.parentName,
      "babyName": this.babyName,
      "babyAge": this.babyAge,
      "lat": this.lat,
      "lon": this.lon,
      "address": this.address,
      "status": this.status,
      "perHourCost": this.perHourCost,
    };
  }
}
