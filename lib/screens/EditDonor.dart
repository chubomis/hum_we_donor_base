import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditDonor extends StatefulWidget {
  final int donorId;
  final Map<String, dynamic> donorData;

  const EditDonor({required this.donorId, required this.donorData, Key? key}) : super(key: key);

  @override
  State<EditDonor> createState() => _EditDonorState();
}

class _EditDonorState extends State<EditDonor> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _tagController;

 @override
void initState() {
  super.initState();
  _nameController = TextEditingController(text: widget.donorData['name']);
  _numberController = TextEditingController(text: widget.donorData['number']);
  _emailController = TextEditingController(text: widget.donorData['email']);
  _addressController = TextEditingController(text: widget.donorData['address']);
  
  // Initialize _tagController with a default value if donorData['tag'] is null
  _tagController = TextEditingController(text: widget.donorData['tag'] ?? '');
}

  Future<void> _updateDonor() async {
    final response = await Supabase.instance.client
        .from('donors')
        .update({
          'name': _nameController.text,
          'number': _numberController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'tag': _tagController.text,
        })
        .eq('id', widget.donorId)
        .select()
        .single();

    if (response != null) {
      Navigator.of(context).pop(response);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating donor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: 'Tag'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateDonor,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
