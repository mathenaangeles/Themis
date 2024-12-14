import 'package:flutter/material.dart';
import 'package:themis/src/authentication/authentication_controller.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  RegistrationState createState() => RegistrationState();
}

class RegistrationState extends State<Registration> {
  final AuthenticationController _authenticationController =
      AuthenticationController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCountry = "Philippines";
  String _selectedCountryCode = "+63";
  String? _errorMessage;

  Future<void> _register() async {
    final userData = {
      'type': 'regular',
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'address': _addressController.text.trim(),
      'country': _selectedCountry,
      'phone': '$_selectedCountryCode${_phoneController.text.trim()}',
      'is_lawyer': false,
    };

    final String? error = await _authenticationController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      userData: userData,
    );

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: ['Philippines']
                  .map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixText: _selectedCountryCode,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
