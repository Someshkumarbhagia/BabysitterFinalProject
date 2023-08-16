import 'dart:math';

import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/booking.model.dart';
import 'package:babysitter/models/requests.model.dart';
import 'package:babysitter/views/auth/login.dart';
import 'package:babysitter/views/babysitter/booking_screen.dart';
import 'package:babysitter/views/babysitter/edit_profile.dart';
import 'package:babysitter/views/babysitter/view_history.dart';
import 'package:babysitter/views/babysitter/view_ratings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BabysitterHome extends StatefulWidget {
  const BabysitterHome({super.key});

  @override
  State<BabysitterHome> createState() => _BabysitterHomeState();
}

class _BabysitterHomeState extends State<BabysitterHome> {
  bool isLoading = true;
  bool isBooking = false;

  String babysitterEmail = "";

  double currentLat = 0.0;
  double currentLon = 0.0;

  Stream<QuerySnapshot<Map<String, dynamic>>> getRequests() {
    print(babysitterEmail);
    return FirebaseFirestore.instance
        .collection("requests")
        .where(
          "babysitterID",
          isEqualTo: babysitterEmail,
        )
        .where(
          "status",
          isEqualTo: "Pending",
        )
        .snapshots();
  }

  @override
  void initState() {
    getBabysitterEmail();
    getActiveBooking();
    getAndSendLocation();
    super.initState();
  }

  getActiveBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email")!;
    var collection = FirebaseFirestore.instance.collection("bookings");

    var docsRef =
        await collection.where("babysitterID", isEqualTo: email).where(
      "status",
      whereIn: ["Awaiting", "Started"],
    ).get();
    if (docsRef.docs.length == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(
            bookingID: docsRef.docs.first.id,
          ),
        ),
        (route) => false,
      );
    } else if (docsRef.docs.length > 1) {
      Fluttertoast.showToast(
        msg:
            "There is a fluctuation in database. Please check overlap before presentation",
      );
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in km
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double _toRadians(degrees) {
    return degrees * pi / 180;
  }

  getBabysitterEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email")!;
    setState(() {
      babysitterEmail = email;
    });
  }

  getAndSendLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      currentLat = _locationData.latitude!;
      currentLon = _locationData.longitude!;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email")!;
    var collection = FirebaseFirestore.instance.collection("babysitters");
    await collection.doc(email).update({
      "lat": _locationData.latitude,
      "lon": _locationData.longitude,
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(
        msg:
            "Your current location wasn't updated, you may not get accurate requests.",
      );
    });
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        backgroundColor: kMainColor,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Image.asset(
              "images/logo.png",
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Divider(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewHistory(),
                  ),
                );
              },
              leading: Icon(
                Icons.attach_money,
                color: Colors.white,
              ),
              title: Text(
                "Earnings & History",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewRatings(),
                  ),
                );
              },
              leading: Icon(
                Icons.rate_review,
                color: Colors.white,
              ),
              title: Text(
                "Ratings",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfile(),
                  ),
                );
              },
              leading: Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              leading: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kMainColor,
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Stack(
                  children: [
                    Image.asset(
                      "images/logo_colored.png",
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                    ),
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Colors.black,
                      onPressed: () async {
                        _globalKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Image.asset(
                  "images/searching.gif",
                ),
                Text(
                  "Searching Requests...",
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Request> requests = [];
                      snapshot.data!.docs.forEach(
                        (element) {
                          Request _req = Request.fromJson(element.data());
                          print(_req.parentName);
                          requests.add(_req);
                        },
                      );
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.43,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            String away = "";
                            int kms = calculateDistance(currentLat, currentLon,
                                    requests[index].lat, requests[index].lon)
                                .ceil();
                            away = kms.toString();
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                elevation: 4,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.person,
                                        color: kMainColor,
                                      ),
                                      trailing: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    child: Wrap(
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons
                                                                .baby_changing_station,
                                                          ),
                                                          title: Text(
                                                            requests[index]
                                                                .babyName,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "Baby Name",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons.numbers,
                                                          ),
                                                          title: Text(
                                                            requests[index]
                                                                .babyAge,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "Baby Age",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons.person,
                                                          ),
                                                          title: Text(
                                                            requests[index]
                                                                .parentName,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "Guardian Name",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons.location_on,
                                                          ),
                                                          title: Text(
                                                            requests[index]
                                                                .address,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "Address",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.info_outline,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            requests[index].babyName,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            " (${requests[index].parentName})",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            away + " km away...",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isBooking)
                                      Center(
                                        child: CircularProgressIndicator(
                                            color: kMainColor),
                                      ),
                                    if (!isBooking)
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            isBooking = true;
                                          });
                                          await FirebaseFirestore.instance
                                              .collection("requests")
                                              .doc(requests[index].id)
                                              .update({
                                            "status": "Accepted",
                                          });
                                          String bookingID = DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();
                                          Booking newBooking = Booking(
                                            id: bookingID,
                                            perHourCost:
                                                requests[index].perHourCost,
                                            parentID: requests[index].parentID,
                                            babysitterID:
                                                requests[index].babysitterID,
                                            parentName:
                                                requests[index].parentName,
                                            babyName: requests[index].babyName,
                                            babyAge: requests[index].babyAge,
                                            address: requests[index].address,
                                            lat: requests[index].lat,
                                            lon: requests[index].lon,
                                            status: "Awaiting",
                                            serviceStartTime: Timestamp(0, 0),
                                            serviceEndTime: Timestamp(0, 0),
                                            driverLat: 0,
                                            driverLon: 0,
                                          );
                                          var collection = FirebaseFirestore
                                              .instance
                                              .collection("bookings");
                                          await collection
                                              .doc(bookingID)
                                              .set(
                                                newBooking.toJson(),
                                              )
                                              .then((value) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Booking successfully created. Please make sure to stay in touch with the Guardian.",
                                            );
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BookingScreen(
                                                  bookingID: bookingID,
                                                ),
                                              ),
                                              (route) => false,
                                            );
                                          });
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                10,
                                              ),
                                              bottomRight: Radius.circular(
                                                10,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: Center(
                                              child: Text(
                                                "Accept",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: CircularProgressIndicator(
                          color: kMainColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
