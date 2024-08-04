import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AddDonation extends StatefulWidget {
  final int donorId;

  const AddDonation({required this.donorId, Key? key}) : super(key: key);

  @override
  _AddDonationState createState() => _AddDonationState();
}

class _AddDonationState extends State<AddDonation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
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

  Future<void> _addDonation() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await Supabase.instance.client
            .from('donations')
            .insert({
              'donor_id': widget.donorId,
              'amount': _amountController.text, // Store the value directly
              'date': _dateController.text, // Store the value directly
              'type': _typeController.text, // Store the value directly
            });

        // Clear the controllers
        _amountController.clear();
        _dateController.clear();
        _typeController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation added successfully')),
        );
        Navigator.of(context).pop(true);
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
        title: const Text("Add Donation"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _amountController,
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
                  controller: _typeController,
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
                  ],
                  onChanged: (value) {
                    switch (value) {
                      case "amount":
                        _amountController.text = "Not Applicable";
                      case "date":
                        _dateController.text = "Not Applicable";
                      case "donationType":
                        _typeController.text = "Not Applicable";
                        break;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _addDonation,
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
