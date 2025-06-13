import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BabyFormScreen extends StatefulWidget {
  const BabyFormScreen({super.key});

  @override
  State<BabyFormScreen> createState() => _BabyFormScreenState();
}

class _BabyFormScreenState extends State<BabyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameOrIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showSnackBar('Location permission denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to get address: $e');
    }
  }

  Future<void> _submitBabyData(
      String nameOrId, String age, String address) async {
    const url = 'http://192.168.0.70:5000/api/add-baby'; // Update IP if needed

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nameOrId': nameOrId,
          'age': age,
          'address': address,
        }),
      );

      print("🔁 Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        _showSnackBar(jsonData["message"] ?? "Baby data saved!");
        _clearForm();

        // Navigate to next screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
        _clearForm();
      } else {
        _showSnackBar('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('🌐 Network error: $e');
    }
  }

  void _startRecording() {
    if (_formKey.currentState!.validate()) {
      final nameOrId = _nameOrIdController.text.trim();
      final age = _ageController.text.trim();
      final address = _addressController.text.trim();

      _submitBabyData(nameOrId, age, address);
    }
  }

  void _clearForm() {
    _nameOrIdController.clear();
    _ageController.clear();
    _addressController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Enter Baby Details'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Baby Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameOrIdController,
                    decoration: InputDecoration(
                      labelText: 'Baby Name or ID',
                      filled: true,
                      fillColor: Colors.pink[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter Baby Name or ID' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age (in weeks)',
                      filled: true,
                      fillColor: Colors.pink[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter age in weeks' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      filled: true,
                      fillColor: Colors.pink[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter or fetch address' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Fetch Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
