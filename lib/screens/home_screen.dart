import 'package:flutter/material.dart';
import 'package:hum_we_donor_base/screens/donor_details.dart';
import 'package:hum_we_donor_base/screens/donors.dart';
import 'package:hum_we_donor_base/screens/create_donor.dart';
import 'package:hum_we_donor_base/screens/my_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _donorsList = [];

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    final response = await Supabase.instance.client
        .from('donors')
        .select('id, name, number, email, address');

    if (response != null) {
      setState(() {
        _donorsList = List<Map<String, dynamic>>.from(response);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading donors')),
      );
    }
  }

  Future<void> _deleteDonor(int id) async {
    try {
      await Supabase.instance.client
          .from('donations')
          .delete()
          .eq('donor_id', id);

      await Supabase.instance.client
          .from('donors')
          .delete()
          .eq('id', id)
          .select();

      setState(() {
        _donorsList.removeWhere((donor) => donor['id'] == id);
      });

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting donor: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("H U M    W E    D O N O R    B A S E"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: ListView.builder(
      itemCount: _donorsList.length,
      itemBuilder: (context, index) {
        final donor = _donorsList[index];
        return Donors(
          donorName: donor['name'],
          donorNumber: donor['number'],
          donorEmail: donor['email'],
          donorAddress: donor['address'],
          onDelete: () => _deleteDonor(donor['id']),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DonorDetails(donorId: donor['id']),
              ),
            );
          },
        );
      },
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateDonor()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
