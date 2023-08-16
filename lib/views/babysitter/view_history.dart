import 'dart:math';

import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/babysitter.model.dart';
import 'package:babysitter/models/booking.model.dart';
import 'package:babysitter/views/babysitter/booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({super.key});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  bool isLoading = true;

  Babysitter? babysitter;
  List<Booking> previousBookings = [];

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
    getPreviousBookings(email);
  }

  getPreviousBookings(String email) async {
    List<Booking> _bookings = [];
    var collection = FirebaseFirestore.instance.collection("bookings");
    var docsRef =
        await collection.where("babysitterID", isEqualTo: email).where(
      "status",
      whereIn: [
        "Completed",
        "Cancelled",
      ],
    ).get();
    docsRef.docs.forEach((element) {
      Booking _booking = Booking.fromJson(element.data());

      _bookings.add(_booking);
    });
    setState(() {
      previousBookings = _bookings;
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
          "Earnings & History",
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
                            Text(
                              "Rs. ${babysitter!.earnings}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "( ${previousBookings.length} bookings )",
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
                      itemCount: previousBookings.length,
                      itemBuilder: (context, index) {
                        Booking booking = previousBookings[index];
                        String totalEarnings = "0";
                        if (booking.status == "Completed") {
                          double chargesPerMinute =
                              int.parse(booking.perHourCost) / 60;
                          var minutesSpent = booking.serviceStartTime
                              .toDate()
                              .difference(booking.serviceEndTime.toDate())
                              .inMinutes;
                          double cost = chargesPerMinute * minutesSpent;
                          print("$chargesPerMinute * $minutesSpent = $cost");
                          totalEarnings = cost.ceil().abs().toString();
                        }
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(
                                    bookingID: booking.id,
                                  ),
                                ),
                              );
                            },
                            leading: Icon(
                              CupertinoIcons.today,
                              color: kMainColor,
                            ),
                            title: Text(
                              previousBookings[index].babyName,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: kMainColor,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Money Earned: ",
                                    style: TextStyle(
                                      color: kMainColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    " Rs. " + totalEarnings,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
