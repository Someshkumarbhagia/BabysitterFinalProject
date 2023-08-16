import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/babysitter.model.dart';
import 'package:babysitter/views/babysitter/babysitter_home.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  String method;
  String email;

  EditProfile({this.email = "", this.method = "email"});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var descriptionController = TextEditingController();
  var chargesPerHourController = TextEditingController();
  var experienceController = TextEditingController();

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool isLoading = false;

  Babysitter? babysitter;

  String docID = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var docRef = await FirebaseFirestore.instance
        .collection("babysitters")
        .where("email", isEqualTo: prefs.getString("email")!)
        .get();
    Babysitter _user = Babysitter.fromJson(
      docRef.docs.first.data(),
    );

    setState(() {
      babysitter = _user;
      docID = docRef.docs.first.id;
      numberController.text = babysitter!.phone.substring(1);
      nameController.text = babysitter!.name;
      descriptionController.text = babysitter!.description;
      experienceController.text = babysitter!.experience;
      chargesPerHourController.text = babysitter!.chargesPerHour;
    });
  }

  saveDetails() async {
    bool isValid = formkey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      Babysitter newBabysitter = Babysitter(
        name: nameController.text,
        email: babysitter!.email,
        password: babysitter!.password,
        method: babysitter!.method,
        phone: "0${numberController.text}",
        description: descriptionController.text,
        experience: experienceController.text,
        chargesPerHour: chargesPerHourController.text,
        lat: babysitter!.lat,
        lon: babysitter!.lon,
        earnings: babysitter!.earnings,
        ratings: babysitter!.ratings,
      );
      await FirebaseFirestore.instance
          .collection("babysitters")
          .doc(docID)
          .update(
            newBabysitter.toJson(),
          )
          .then(
        (value) {
          Fluttertoast.showToast(
            msg: "Profile saved successfully!",
          );
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    MediaQueryData queryData; //
    queryData = MediaQuery.of(context); //
    double pixels = queryData.devicePixelRatio; //

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(//to avoid pixel problem
          children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            children: [
              Container(
                width: w,
                height: h * 0.28,
                decoration: BoxDecoration(
                  color: kMainColor,
                  image: DecorationImage(
                    image: AssetImage("images/logo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Form(
                key: formkey,
                child: Container(
                  width: w,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Text(
                        'Edit Profile.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 35),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.length != 10) {
                              return "         Please enter a valid 10 digit phone number";
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.deny(RegExp('^0+'))
                          ],
                          controller: numberController,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.black54,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.trim().length < 4)
                              return "          Please enter a valid full name";
                            if (!value.contains(" ")) {
                              return "          Please enter a valid full name";
                            }
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Full Name",
                            prefixIcon:
                                Icon(Icons.abc_outlined, color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: Offset(1, 1),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.trim().length < 50)
                                return "          Please enter atleast 50 characters.";
                            },
                            controller: descriptionController,
                            maxLines: 6,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: "Describe yourself...",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.trim().length < 1)
                              return "          Please enter valid experience years";
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          controller: experienceController,
                          decoration: InputDecoration(
                            hintText: "Experience (in years, eg: 2)",
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefixIcon:
                                Icon(Icons.work_history, color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.trim().length < 1)
                              return "          Please enter valid charges";
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          controller: chargesPerHourController,
                          decoration: InputDecoration(
                            hintText: "Charges (per hour, eg: 750)",
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.monetization_on_outlined,
                                color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      saveDetails();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(width: 2),
                          color: kMainColor),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Save Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: w * 0.15),
            ],
          ),
        ),
      ]),
    );
  }
}
