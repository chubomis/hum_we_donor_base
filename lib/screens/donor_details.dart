import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hum_we_donor_base/screens/add_donation.dart';

class DonorDetails extends StatefulWidget {
  final int donorId;

  const DonorDetails({required this.donorId, super.key});

  @override
  State<DonorDetails> createState() => _DonorDetailsState();
}

class _DonorDetailsState extends State<DonorDetails> {
  Map<String, dynamic>? _donorDetails;
  List<Map<String, dynamic>> _donations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonorDetails();
    _fetchDonorDonations();
  }

  Future<void> _fetchDonorDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('donors')
          .select('id, name, number, email, address, tag')
          .eq('id', widget.donorId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _donorDetails = response as Map<String, dynamic>?;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading donor details')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donor details: $error')),
      );
    }
  }

  Future<void> _fetchDonorDonations() async {
    try {
      final response = await Supabase.instance.client
          .from('donations')
          .select('amount, date, type')
          .eq('donor_id', widget.donorId);

      if (response != null) {
        setState(() {
          _donations = List<Map<String, dynamic>>.from(response);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading donor donations')),
        );
      }
    } catch (error) {
      if (error is PostgrestException && error.code == '42P01') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donations table does not exist')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading donor donations: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Details'),
        centerTitle: true,
      ),
      body: _donorDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_donorDetails!['name']}', style: Theme.of(context).textTheme.titleLarge),
                  Text('Number: ${_donorDetails!['number']}', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Email: ${_donorDetails!['email']}', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Address: ${_donorDetails!['address']}', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Tag: ${_donorDetails!['tag']}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  const Text('Donations:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _donations.length,
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return ListTile(
                          title: Text('Amount: ${donation['amount']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${donation['date']}'),
                              Text('Type: ${donation['type']}'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to the AddDonation screen and wait for a result
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddDonation(donorId: widget.donorId),
                        ),
                      );

                      // Check if the result is true (indicating a successful donation addition)
                      if (result == true) {
                        _fetchDonorDonations(); // Refresh the donations list
                      }
                    },
                    child: const Text('Add Donation'),
                  ),
                ],
              ),
            ),
    );
  }
}
