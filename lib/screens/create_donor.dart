import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:hum_we_donor_base/screens/my_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateDonor extends StatefulWidget {
  const CreateDonor({super.key});

  @override
  State<CreateDonor> createState() => _CreateDonorState();
}

class _CreateDonorState extends State<CreateDonor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _donationAmountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _donationTypeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Extract the text from the controllers
        String name = _nameController.text;
        String phone = _phoneController.text;
        String address = _addressController.text;
        String email = _emailController.text;
        String amount = _donationAmountController.text;
        String date = _dateController.text;
        String type = _donationTypeController.text;
        String tag = _tagController.text;

        // Insert donor details into the donors table
        final donorResponse = await Supabase.instance.client
            .from('donors')
            .insert({
              'name': name,
              'number': phone,
              'address': address,
              'email': email,
              'tag': tag
            })
            .select()
            .single();

        if (donorResponse != null) {
          final donorId = donorResponse['id'];

          // Insert donation details into the donations table
          await Supabase.instance.client.from('donations').insert({
            'donor_id': donorId,
            'amount': amount,
            'date': date,
            'type': type,
          });

          // Clear the controllers
          _nameController.clear();
          _phoneController.clear();
          _addressController.clear();
          _emailController.clear();
          _donationAmountController.clear();
          _dateController.clear();
          _donationTypeController.clear();
          _tagController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donor and donation added successfully')),
          );
        } else {
          throw Exception('Failed to insert donor');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("C R E A T E    D O N O R"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Donor's Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the donor's name";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Donor's Telephone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the donor's telephone number";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Donor's Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the donor's address";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email of Donor",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the donor's email";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _donationAmountController,
                  decoration: const InputDecoration(
                    labelText: "Donation Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the amount of donation";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: "Date of Donation",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the date of donation";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _donationTypeController,
                  decoration: const InputDecoration(
                    labelText: "Donation Type",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the type of donation";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: "Tag this Donor",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please tag this donor";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Not Applicable",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "name",
                      child: Text("Donor's Name"),
                    ),
                    DropdownMenuItem(
                      value: "phone",
                      child: Text("Donor's Telephone Number"),
                    ),
                    DropdownMenuItem(
                      value: "address",
                      child: Text("Donor's Address"),
                    ),
                    DropdownMenuItem(
                      value: "email",
                      child: Text("Email of Donor"),
                    ),
                    DropdownMenuItem(
                      value: "amount",
                      child: Text("Amount of Donation"),
                    ),
                    DropdownMenuItem(
                      value: "date",
                      child: Text("Date of Donation"),
                    ),
                    DropdownMenuItem(
                      value: "donationType",
                      child: Text("Donation Type"),
                    ),
                    DropdownMenuItem(
                      value: "tag",
                      child: Text("Donor's Tag"),
                    ),
                  ],
                  onChanged: (value) {
                    switch (value) {
                      case "name":
                        _nameController.text = "Not Applicable";
                        break;
                      case "phone":
                        _phoneController.text = "Not Applicable";
                        break;
                      case "address":
                        _addressController.text = "Not Applicable";
                        break;
                      case "email":
                        _emailController.text = "Not Applicable";
                        break;
                      case "amount":
                        _donationAmountController.text = "Not Applicable";
                        break;
                      case "date":
                        _dateController.text = "Not Applicable";
                        break;
                      case "donationType":
                        _donationTypeController.text = "Not Applicable";
                        break;
                      case "tag":
                        _tagController.text = "Not Applicable";
                        break;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
