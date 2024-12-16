import 'package:book_store/account/order.dart';
import 'package:flutter/material.dart';



class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _phone = "";
  String _address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressScreen(
                          name: _name,
                          phone: _phone,
                          address: _address,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String address;

  const AddressScreen({super.key, required this.name, required this.phone, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Phone: $phone', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Address: $address', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the order section (example placeholder)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderScreen(),
                  ),
                );
              },
              child: const Text('Proceed to Order'),
            ),
          ],
        ),
      ),
    );
  }
}


