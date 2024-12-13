import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/screens/login_screen.dart';

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
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _handleSignUp,
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
                                color: Colors.white,
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

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Set additional user details
        User? user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          // await user.updatePhoneNumber(_phoneController.text.trim());
          // Save phone number using custom claims or Firestore (if required)
          await user.reload(); // Ensure changes are reflected in the current session
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-Up successful!")),
        );

        Navigator.pop(context); // Go back to the previous screen (e.g., Login)
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Sign-Up failed")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
