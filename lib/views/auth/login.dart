import 'package:babysitter/config/constants.dart';
import 'package:babysitter/views/babysitter/babysitter_home.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:babysitter/models/babysitter.model.dart' as AppUser;
import 'package:babysitter/views/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var numberController = TextEditingController();

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool isLoading = false;

  login() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var collection = FirebaseFirestore.instance.collection('babysitters');
      var docSnapshot = await collection
          .where("email", isEqualTo: emailController.text)
          .limit(1)
          .get();
      if (docSnapshot.size == 1) {
        if (docSnapshot.docs.first.data()['method'] == "google") {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg:
                  "This account is registered via Google Sign In. Please use Google Sign In to login.");
        } else {
          final bool checkPassword = BCrypt.checkpw(passwordController.text,
              docSnapshot.docs.first.data()['password']);
          if (checkPassword) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("email", emailController.text);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BabysitterHome(),
              ),
              (route) => false,
            );
          } else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Invalid password!");
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Invalid user!");
      }
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential creds =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(creds.user!.email);
    var fetchedEmail = creds.user!.email;
    var fetchedName = creds.user!.displayName;
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    // FIREBASE AUTH ENDS HERE
    var collection = FirebaseFirestore.instance.collection('babysitters');
    var docSnapshot =
        await collection.where("email", isEqualTo: fetchedEmail).limit(1).get();
    if (docSnapshot.size == 1) {
      if (docSnapshot.docs.first.data()['method'] == "google") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", fetchedEmail!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => BabysitterHome(),
          ),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(
            msg:
                "This user is not registered through google, please enter your password");
        setState(() {
          emailController.text = fetchedEmail!;
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "This is your first login, please enter some details...");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SignupScreen(
            method: "google",
            email: fetchedEmail!,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        //to avoid pixel problem
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
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: kMainColor,
                            ),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (!value!.contains("@") ||
                                  !value.contains(".")) {
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
                            border: Border.all(
                              color: kMainColor,
                            ),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.length < 6) {
                                return "          Password must be at least 6 characters";
                              }
                            },
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon:
                                  Icon(Icons.password, color: Colors.black54),
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
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
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
                      onTap: login,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(width: 2),
                            color: kMainColor),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 15),
                if (!isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: GestureDetector(
                      onTap: signInWithGoogle,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(width: 2),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          leading: Image.asset("images/g.png"),
                          title: Center(
                            child: Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don\'t have an account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "DGO",
                        color: Colors.grey[500],
                      ),
                      children: [
                        TextSpan(
                          text: " Create",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
