import 'dart:math';

import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/babysitter.model.dart';
import 'package:babysitter/models/booking.model.dart';
import 'package:babysitter/models/review.model.dart';
import 'package:babysitter/views/babysitter/booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRatings extends StatefulWidget {
  const ViewRatings({super.key});

  @override
  State<ViewRatings> createState() => _ViewRatingsState();
}

class _ViewRatingsState extends State<ViewRatings> {
  bool isLoading = true;

  Babysitter? babysitter;
  List<Review> allRatings = [];

  @override
  void initState() {
    getBabysitter();
    super.initState();
  }

  getBabysitter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email")!;
    var collection = FirebaseFirestore.instance.collection("babysitters");
    var docRef = await collection.doc(email).get();
    Babysitter _bs = Babysitter.fromJson(docRef.data()!);
    setState(() {
      babysitter = _bs;
    });
    getAllRatings(email);
  }

  getAllRatings(String email) async {
    List<Review> _reviews = [];
    var collection = FirebaseFirestore.instance.collection("reviews");
    var docsRef = await collection
        .where("babysitterID", isEqualTo: email)
        .where(
          "status",
          isEqualTo: "Completed",
        )
        .get();
    docsRef.docs.forEach((element) {
      Review _booking = Review.fromJson(element.data());

      _reviews.add(_booking);
    });
    setState(() {
      allRatings = _reviews;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: kMainColor,
        ),
        title: Text(
          "Reviews",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  SizedBox(



                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      elevation: 4,
                      color: kMainColor,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Text(
                              "Total Earnings",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${babysitter!.ratings}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "( ${allRatings.length} reviews )",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.68,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: allRatings.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.star,
                              color: kMainColor,
                            ),
                            trailing: Text(
                              allRatings[index].rating.toString(),
                            ),
                            title: Text(
                              allRatings[index].parentName.toString(),
                            ),
                            subtitle: Text(
                              allRatings[index].review.trim().isEmpty
                                  ? "No Comments"
                                  : allRatings[index].review,
                              style: TextStyle(
                                color: kMainColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
