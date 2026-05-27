import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'package:http/http.dart' as http;
import '/models/register_model.dart';
import '/services/register_service.dart';
import 'main.dart';
import 'utils/app_layout.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerAndLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Validate required fields
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception(
            'Please fill all required fields (Name, Email, Password)');
      }

      // Create the request object
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );

      // Call the registration API
      final registerService = RegisterService(client: http.Client());
      final response = await registerService.registerUser(registerRequest);

      if (!mounted) return;

      if (response.status == 'SUCCESS') {
        successSnackBar('Success', 'Registration successful!');

        // Navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      } else {
        throw Exception(response.message ?? 'Registration failed');
      }
    } catch (e) {
      if (!mounted) return;
      errorSnackBar('Error', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
        backgroundColor: AppColor.primary,
        titleTextStyle: const TextStyle(
          color: AppColor.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: AppColor.scaffoldBackground,
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/logo1.png', height: 150, width: 500),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: Text(
                  'Please register to login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              _buildTextField("Name", Icons.person, _nameController),
              const SizedBox(height: 10),

              // Email
              _buildTextField("Email", Icons.email, _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),

              // Password
              _buildPasswordField(),
              const SizedBox(height: 20),

              // Register Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: _registerAndLogin,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColor.white,
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColor.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyHomePage(title: 'Login Page'),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.disabledBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: AppColor.primary,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.disabledBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _isObscure,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(
                Icons.lock,
                color: AppColor.primary,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.primary,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
