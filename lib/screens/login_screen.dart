import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDB2367), // Pinkish background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
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
              SizedBox(height: 60),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome Text
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Aclonica',
                            color: Color(0xFFFF007F),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "login to continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Aclonica',
                            color: Color(0xFFFF007F),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: TextStyle(
                              color: Color(0xFFFF007F),
                              fontSize: 13,
                              fontFamily: 'Aclonica',
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
                              return 'Please enter an email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: TextStyle(
                              color: Color(0xFFFF007F),
                              fontSize: 13,
                              fontFamily: 'Aclonica',
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFFDB2367),
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Login Button
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              final email = _emailController.text.trim();
                              final password =
                              _passwordController.text.trim();

                              bool confirm = await _loginUser(email, password);
                              setState(() {
                                _isLoading = false;
                              });
                              if (!confirm) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Login failed. Please try again."),
                                  ),
                                );
                              }
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
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                              fontFamily: "Aclonica"
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Sign Up Option
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Don't have an account?",
                            style: TextStyle(
                                color: Color(0xFFDB2367),
                                fontFamily: "Aclonica"
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
    );
  }

  Future<bool> _loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushNamed(context, '/home');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return false;
    }
  }
}
