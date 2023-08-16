import 'dart:async';

import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/booking.model.dart';
import 'package:babysitter/models/review.model.dart';
import 'package:babysitter/views/babysitter/babysitter_home.dart';
import 'package:babysitter/views/babysitter/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends StatefulWidget {
  String bookingID;
  BookingScreen({required this.bookingID});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isLoading = false;

  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition position = CameraPosition(
    target: LatLng(24.819278, 67.030787),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _listenLocationAndUpdate(widget.bookingID);
  }

  _listenLocationAndUpdate(String id) async {
    Booking? booking;

    var collection = FirebaseFirestore.instance.collection("bookings");
    var doc = await collection.doc(widget.bookingID).get();
    booking = Booking.fromJson(doc.data()!);

    if (booking.status == "Awaiting") {
      location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 25000,
      );
      location.enableBackgroundMode(enable: true);

      locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        FirebaseFirestore.instance.collection("bookings").doc(id).update(
          {
            "driverLat": currentLocation.latitude!,
            "driverLon": currentLocation.longitude!,
          },
        );
      });
    }
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getBooking() {
    return FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.bookingID)
        .snapshots();
  }

  startService() async {
    var collection = FirebaseFirestore.instance.collection("bookings");
    await collection.doc(widget.bookingID).update({
      "status": "Started",
      "serviceStartTime": Timestamp.fromDate(
        DateTime.now(),
      ),
    }).then((value) {
      Fluttertoast.showToast(msg: "Service started successfully.");
    });
  }

  endService(Booking booking) async {
    setState(() {
      isLoading = true;
    });
    var collection = FirebaseFirestore.instance.collection("bookings");
    await collection.doc(widget.bookingID).update({
      "status": "Completed",
      "serviceEndTime": Timestamp.fromDate(
        DateTime.now(),
      ),
    }).then((value) async {
      var docRef = await collection.doc(widget.bookingID).get();
      Booking _booking = Booking.fromJson(docRef.data()!);
      double chargesPerMinute = int.parse(_booking.perHourCost) / 60;
      var minutesSpent = _booking.serviceStartTime
          .toDate()
          .difference(_booking.serviceEndTime.toDate())
          .inMinutes;
      double cost = chargesPerMinute * minutesSpent;
      int totalCost = cost.ceil().abs();
      var bsDoc = await FirebaseFirestore.instance
          .collection("babysitters")
          .doc(_booking.babysitterID)
          .get();
      int newEarnings = int.parse(
            bsDoc.data()!['earnings'].toString(),
          ) +
          totalCost;
      await FirebaseFirestore.instance
          .collection("babysitters")
          .doc(_booking.babysitterID)
          .update(
        {
          "earnings": newEarnings,
        },
      );
      String reviewID = DateTime.now().millisecondsSinceEpoch.toString();
      Review review = Review(
        id: reviewID,
        babysitterID: booking.babysitterID,
        babysitterName: bsDoc.data()!['name'],
        parentID: booking.parentID,
        parentName: booking.parentName,
        review: "",
        rating: 0,
        createdAt: Timestamp.now(),
        status: "Pending",
      );
      await FirebaseFirestore.instance.collection("reviews").doc(reviewID).set(
            review.toJson(),
          );
      Fluttertoast.showToast(
        msg:
            "Service ended successfully. Please check the booking details section for total cost of this booking",
      );
      setState(() {
        isLoading = false;
      });
    });
  }

  cancelService() async {
    var collection = FirebaseFirestore.instance.collection("bookings");
    await collection.doc(widget.bookingID).update({
      "status": "Cancelled",
    }).then((value) {
      Fluttertoast.showToast(msg: "Service cancelled successfully.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BabysitterHome(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(
          msg: "You can not do other functions during an active booking",
        );
        return false;
      },
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: getBooking(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Booking booking = Booking.fromJson(snapshot.data!.data()!);
              String totalCost = "";
              if (booking.status == "Completed") {
                double chargesPerMinute = int.parse(booking.perHourCost) / 60;
                var minutesSpent = booking.serviceStartTime
                    .toDate()
                    .difference(booking.serviceEndTime.toDate())
                    .inMinutes;
                double cost = chargesPerMinute * minutesSpent;
                print("$chargesPerMinute * $minutesSpent = $cost");
                totalCost = cost.ceil().abs().toString();
              }
              return Scaffold(
                bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      Center(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: CircularProgressIndicator()),
                      ),
                    if (booking.status == "Started")
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            endService(booking);
                          },
                          child: Container(
                            height: 50,
                            color: kMainColor,
                            child: Center(
                              child: Text(
                                "End Service",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (booking.status == "Awaiting")
                      Expanded(
                        child: GestureDetector(
                          onTap: startService,
                          child: Container(
                            height: 50,
                            color: kMainColor,
                            child: Center(
                              child: Text(
                                "Start Service",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (booking.status == "Awaiting")
                      Expanded(
                        child: Container(
                          height: 50,
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              "Cancel Booking",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: SafeArea(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          leading: booking.status != "Awaiting" &&
                                  booking.status != "Started"
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BabysitterHome(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: kMainColor,
                                  ),
                                )
                              : null,
                          title: Center(
                            child: Text(
                              "Booking #${widget.bookingID}",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (booking.status != "Completed" &&
                            booking.status != "Cancelled")
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    attenderEmail: booking.babysitterID,
                                    attenderName: "Babysitter",
                                    bookingID: widget.bookingID,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  "Chat Now",
                                ),
                                subtitle: Text(
                                  "Chat with the parent and keep them updated.",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                                trailing: Icon(
                                  CupertinoIcons.chat_bubble,
                                  color: kMainColor,
                                ),
                              ),
                            ),
                          ),
                        if (booking.status != "Completed" &&
                            booking.status != "Cancelled")
                          SizedBox(
                            height: 20,
                          ),
                        if (booking.status != "Completed" &&
                            booking.status != "Cancelled")
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                launch(
                                  "https://www.google.com/maps?q=${booking.lat},${booking.lon}&z=17&hl=en",
                                );
                              },
                              title: Text(
                                "View Location",
                              ),
                              subtitle: Text(
                                "See booked house's address to reach them.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                              trailing: Icon(
                                CupertinoIcons.location,
                                color: kMainColor,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: Text(
                                  "Booking Details",
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (booking.status == "Completed")
                                ListTile(
                                  leading: Icon(
                                    Icons.monetization_on,
                                  ),
                                  title: Text(
                                    "Rs. " + totalCost,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Total Cost",
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ListTile(
                                leading: Icon(
                                  Icons.start,
                                ),
                                title: Text(
                                  booking.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  "Booking Status",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.baby_changing_station,
                                ),
                                title: Text(
                                  booking.babyName,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  "Baby Name",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.numbers,
                                ),
                                title: Text(
                                  booking.babyAge,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  "Baby Age",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.person,
                                ),
                                title: Text(
                                  booking.parentName,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  "Guardian Name",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                ),
                                title: Text(
                                  booking.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  "Address",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: kMainColor,
              ),
            );
          }),
    );
  }
}
