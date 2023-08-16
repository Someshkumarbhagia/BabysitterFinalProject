class Babysitter {
  String name;
  String email;
  String password;
  String method;
  String phone;
  String description;
  String experience;
  String chargesPerHour;
  double lat;
  double lon;
  String earnings;
  String ratings;

  Babysitter({
    required this.name,
    required this.email,
    required this.password,
    required this.method,
    required this.phone,
    required this.description,
    required this.experience,
    required this.chargesPerHour,
    required this.lat,
    required this.lon,
    required this.earnings,
    required this.ratings,
  });

  factory Babysitter.fromJson(Map<String, dynamic> json) {
    return Babysitter(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      method: json['method'],
      phone: json['phone'],
      description: json['description'],
      experience: json['experience'],
      chargesPerHour: json['chargesPerHour'],
      lat: json['lat'],
      lon: json['lon'],
      earnings: json['earnings'].toString(),
      ratings: json['ratings'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "email": this.email,
      "password": this.password,
      "method": this.method,
      "phone": this.phone,
      "description": this.description,
      "experience": this.experience,
      "chargesPerHour": this.chargesPerHour,
      "lat": this.lat,
      "lon": this.lon,
      "earnings": this.earnings,
      "ratings": this.ratings,
    };
  }
}
