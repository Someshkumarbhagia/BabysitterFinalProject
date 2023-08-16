import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String id;
  String babysitterID;
  String babysitterName;
  String parentID;
  String parentName;
  String review;
  int rating;
  Timestamp createdAt;
  String status;

  Review({
    required this.id,
    required this.babysitterID,
    required this.babysitterName,
    required this.parentID,
    required this.parentName,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.status,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      babysitterID: json['babysitterID'],
      babysitterName: json['babysitterName'],
      parentID: json['parentID'],
      parentName: json['parentName'],
      review: json['review'],
      rating: json['rating'],
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "babysitterID": this.babysitterID,
      "babysitterName": this.babysitterName,
      "parentID": this.parentID,
      "parentName": this.parentName,
      "review": this.review,
      "rating": this.rating,
      "createdAt": this.createdAt,
      "status": this.status,
    };
  }
}
