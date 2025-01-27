import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hum_we_donor_base/screens/EditDonor.dart';
import 'package:hum_we_donor_base/screens/donor_details.dart';
import 'package:hum_we_donor_base/screens/donors.dart';
import 'package:hum_we_donor_base/screens/create_donor.dart';
import 'package:hum_we_donor_base/screens/my_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _donorsList = [];
  TextEditingController filterController = TextEditingController(text: 'any');

  @override
  void initState() {
    super.initState();
    _loadDonors();
    filterController.text = '';
  }

  Future<void> _loadDonors() async {
    final response = await Supabase.instance.client
        .from('donors')
        .select('id, name, number, email, address, tag');

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

  Future<void> _editDonor(int id) async {
    final donor = _donorsList.firstWhere((donor) => donor['id'] == id);

    final updatedDonor = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => EditDonor(
          donorId: id,
          donorData: donor,
        ),
      ),
    );

    if (updatedDonor != null) {
      setState(() {
        final index = _donorsList.indexWhere((donor) => donor['id'] == id);
        _donorsList[index] = updatedDonor;
      });
    }
  }

  Future<void> _filterDonors() async {
    String filterTag = filterController.text.trim();

    if (filterTag.isEmpty || filterTag.toLowerCase() == 'any') {
      _loadDonors(); // Show all donors if filter is 'any' or empty
    } else {
      final response = await Supabase.instance.client
          .from('donors')
          .select('id, name, number, email, address, tag')
          .ilike('tag', filterTag);

      if (response.isNotEmpty) {
        setState(() {
          _donorsList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          _donorsList = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No donors found with the tag: $filterTag')),
        );
      }
    }
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Filter for Donor'),
          content: TextField(
            controller: filterController,
            decoration: InputDecoration(hintText: 'Enter a tag or "any"'),
          ),
          actions: [
            TextButton(
              child: Text('SEARCH'),
              onPressed: () {
                Navigator.of(context).pop();
                _filterDonors();
              },
            ),
          ],
        ),
      );

  Future<void> _exportToExcel() async {
  try {
    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Donors.xlsx';
    final file = File(path);

    // Load the existing Excel document or create a new one
    var excel;
    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      excel = Excel.decodeBytes(bytes);
    } else {
      excel = Excel.createExcel();
    }

    Sheet sheetObject = excel['Donors'];

    // Define the headers only if the sheet is empty (newly created)
    if (sheetObject.maxRows == 0) {
      List<CellValue?> headers = [
        TextCellValue('ID'),
        TextCellValue('Name'),
        TextCellValue('Number'),
        TextCellValue('Email'),
        TextCellValue('Address'),
        TextCellValue('Tag'),
        TextCellValue('Donations')
      ];
      sheetObject.appendRow(headers);
    }

    // Create a map of existing donors in the sheet by ID
    Map<int, int> donorRowIndexMap = {};
    for (int i = 1; i < sheetObject.maxRows; i++) {
      var row = sheetObject.row(i);
      if (row.isNotEmpty) {
        int donorId = int.parse(row[0]!.value.toString());
        donorRowIndexMap[donorId] = i;
      }
    }

    // Update or add data rows with donations
    for (var donor in _donorsList) {
      // Fetch donations for the current donor
      final donationsResponse = await Supabase.instance.client
          .from('donations')
          .select('amount, date')
          .eq('donor_id', donor['id']);

      List<String> donationDetails = [];
      if (donationsResponse.isNotEmpty) {
        for (var donation in donationsResponse) {
          donationDetails.add(
              'Amount: ${donation['amount']}, Date: ${donation['date']}');
        }
      } else {
        donationDetails.add('No donations found');
      }

      String donationsString = donationDetails.join('; ');

      if (donorRowIndexMap.containsKey(donor['id'])) {
        // Donor exists, update the entire row with new donor information
        int rowIndex = donorRowIndexMap[donor['id']]!;
        
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
          TextCellValue(donor['name']),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
          TextCellValue(donor['number'].toString()),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
          TextCellValue(donor['email']),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
          TextCellValue(donor['address']),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
          TextCellValue(donor['tag']),
        );
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
          TextCellValue(donationsString),
        );
      } else {
        // Donor does not exist, add a new row
        List<CellValue?> row = [
          TextCellValue(donor['id'].toString()),  // Convert int to String
          TextCellValue(donor['name']),
          TextCellValue(donor['number'].toString()),  // Convert int to String if necessary
          TextCellValue(donor['email']),
          TextCellValue(donor['address']),
          TextCellValue(donor['tag']),
          TextCellValue(donationsString)  // Add donations next to the donor
        ];
        sheetObject.appendRow(row);
      }
    }

    // Save the updated file
    await file.writeAsBytes(excel.encode()!);

    // Notify the user of success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donors exported to $path')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error exporting donors: $error')),
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
        actions: [
          IconButton(
            onPressed: () => openDialog(),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.file_download),
          ),
        ],
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
            donorTag: donor['tag'],
            onDelete: () => _deleteDonor(donor['id']),
            onEdit: () => _editDonor(donor['id']),
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
