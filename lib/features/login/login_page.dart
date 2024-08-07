// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, use_build_context_synchronously, depend_on_referenced_packages, implementation_imports

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:plant_shield_app/features/Components/constants.dart';
import 'package:plant_shield_app/features/forgetPassword/forget-password-page.dart';
import 'package:plant_shield_app/features/home/home_page.dart';
import 'package:plant_shield_app/features/Components/loader.dart';
import 'package:plant_shield_app/features/signup/signup-page.dart';
import 'package:plant_shield_app/models/user.dart';
import 'package:plant_shield_app/services/user-service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscurePassword = true;
  bool _hasText = false;
  late SharedPreferences loginUser;
  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    loginUser = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() async {
    if (_formKey.currentState!.validate()) {
      Response? response;
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      try {
        LoadingDialog.showLoadingDialog(context);
        response = await _userService.loginUser(
            _usernameController.text, _passwordController.text,deviceToken ?? '');
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        Navigator.of(context).pop();
      }
      if (response != null && response.statusCode == 200) {
        loginUser.setBool('login', false);
        await setUserObjIntoSharedPreferences(_usernameController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Map<String, dynamic> errorJson = jsonDecode(response!.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorJson['error']),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> setUserObjIntoSharedPreferences(String username) async {
    final User? userObj = await _userService.getLoggedInUser(username);
    if (userObj != null) {
      loginUser.setString("userObj", jsonEncode(userObj.toJson()));
    }
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 4,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Stack(children: [
                  //logo
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.5 - 150,
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/logo2.png',
                        height: 300,
                      ),
                    ),
                  ),

                  //username and password
                  Container(
                    padding: EdgeInsets.only(
                      top: size.height * 0.35,
                      right: 10,
                      left: 10,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: TextFormField(
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                              decoration: constantInputDecoration(
                                  hintText: 'Username',
                                  suffixImagePath: 'assets/user.png'),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter your Password";
                                }
                                return null;
                              },
                              obscureText: _isObscurePassword,
                              onChanged: (value) {
                                setState(() {
                                  _hasText = value.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                fillColor: Colors.grey.shade100,
                                hintText: 'Password',
                                hintStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isObscurePassword =
                                              !_isObscurePassword;
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Icon(
                                          _hasText
                                              ? (_isObscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility)
                                              : null,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _hasText
                                          ? SizedBox.shrink()
                                          : Image.asset(
                                              'assets/lock.png',
                                              width: 24,
                                              height: 24,
                                            ),
                                    ),
                                  ],
                                ),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Constants.primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // forget password
                          Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: size.width * 0.6),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForgetPasswordScreen()));
                                  },
                                  child: Text(
                                    'Forget Password?',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 10,
                                      color: Color(0xFFFF0000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 5),
//sign in button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 255,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _logIn,
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Constants.primaryColor),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30))),
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
//dividers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 150,
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                  height: 90,
                                ),
                              ),
                              Text('or',
                                  style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontSize: 16)),
                              Container(
                                width: 150,
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                  height: 90,
                                ),
                              ),
                            ],
                          ),
//dont have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dont have an account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xfff4c505b),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupScreen()),
                                  );
                                },
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Constants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ]))));
  }
}
