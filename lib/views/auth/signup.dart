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

class SignupScreen extends StatefulWidget {
  String method;
  String email;

  SignupScreen({this.email = "", this.method = "email"});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var numberController = TextEditingController();
  var descriptionController = TextEditingController();
  var chargesPerHourController = TextEditingController();
  var experienceController = TextEditingController();

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool isLoading = false;

  signup() async {
    bool isValid = formkey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      Babysitter newBabysitter = Babysitter(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        method: widget.method,
        phone: numberController.text,
        description: descriptionController.text,
        experience: experienceController.text,
        chargesPerHour: chargesPerHourController.text,
        lat: 0,
        lon: 0,
        earnings: "0",
        ratings: "0.0",
      );
      var collection = FirebaseFirestore.instance.collection('babysitters');
      var docSnapshot =
          await collection.where("email", isEqualTo: newBabysitter.email).get();

      if (docSnapshot.docs.length == 0) {
        newBabysitter.password = BCrypt.hashpw(
          newBabysitter.password,
          BCrypt.gensalt(),
        );
        final docUser = FirebaseFirestore.instance
            .collection('babysitters')
            .doc(newBabysitter.email);
        final userJson = newBabysitter.toJson();
        await docUser.set(userJson).onError((error, stackTrace) {
          Fluttertoast.showToast(
              msg:
                  "An error occured while trying to register your account, please try again later.");
          Navigator.pop(context);
        }).then((value) async {
          Fluttertoast.showToast(
              msg: "Account created successfully, please login.");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("email", newBabysitter.email);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BabysitterHome(),
            ),
            (route) => false,
          );
        });
      } else {
        Fluttertoast.showToast(
            msg:
                "This email is already registered with another account, please login or use another email address.");
        setState(() {
          isLoading = false;
        });
      }
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
                        'Please provide us with some of your details.',
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
                            if (!value!.contains("@") || !value.contains(".")) {
                              return "          Please enter a valid email address";
                            }
                          },
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon:
                                Icon(Icons.email, color: Colors.black54),
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
                          controller: passwordController,
                          validator: (value) {
                            if (value!.length < 6) {
                              return "          Please enter atleast 6 characters";
                            }
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.password_outlined,
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
                      signup();
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
                            "Sign Up",
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
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account?",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
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
