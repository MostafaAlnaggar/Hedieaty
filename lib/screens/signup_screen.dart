import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/screens/login_screen.dart';

import '../controllers/user_controller.dart';
import '../models/user.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDB2367),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hedieaty',
                      style: TextStyle(
                        fontFamily: 'LobsterTwo',
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Image.asset(
                      'assets/icons/Gift_title_Icon.png',
                      height: 36.0,
                      width: 36.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create an Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontFamily: 'Aclonica',
                              color: Color(0xFFFF007F),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Sign up to get started",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Aclonica',
                              color: Color(0xFFFF007F),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: "FULL NAME",
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _emailController,
                            label: "EMAIL",
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _phoneController,
                            label: "PHONE NUMBER",
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _passwordController,
                            label: "PASSWORD",
                            obscureText: _passwordVisible,
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: "CONFIRM PASSWORD",
                            obscureText: _passwordVisible,
                          ),
                          SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), // Yellow color
                        )
                            : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _handleSignUp(
                                context,
                                _nameController.text,
                                _emailController.text,
                                _phoneController.text,
                                _passwordController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD700), // Yellow color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            "SIGN-UP",
                            style: TextStyle(
                              color: Color(0xFFDB2367),
                              fontFamily: "Aclonica",
                            ),
                          ),
                        ),

                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                            child: Text(
                              "Already have an Account?",
                              style: TextStyle(
                                color: Color(0xFFDB2367),
                                fontFamily: "Aclonica",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Color(0xFFDB2367),
          fontFamily: "Aclonica",
        ),
        filled: true,
        fillColor: Colors.grey[200], // Faded grey background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF007F)),
          borderRadius: BorderRadius.circular(40.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF007F)),
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please fill this field';
        }
        if (label == "PHONE NUMBER" && value.length < 10) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  void _handleSignUp(BuildContext context, String name, String email, String phone, String password) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Create a UserModel instance
      UserModel user = UserModel(
        uid: '', // Placeholder; this will be populated in Firestore after signup
        name: name,
        email: email,
        phone: phone,
      );

      // Instantiate the UserController
      UserController userController = UserController();

      // Call the signUp function
      String? result = await userController.signUp(user, password);

      if (result == null) {
        // Signup successful
        Navigator.pushNamed(context, '/home'); // Navigate to the home screen
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }


}
