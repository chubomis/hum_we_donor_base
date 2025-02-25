import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Donors extends StatelessWidget {
  final String donorName;
  final String donorNumber;
  final String donorEmail;
  final String donorAddress;
  final String donorTag;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const Donors({
    required this.donorName,
    required this.donorNumber,
    required this.donorEmail,
    required this.donorAddress,
    required this.donorTag,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(), // Handle the edit action here
              backgroundColor: Colors.grey,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => onDelete(), // Handle the delete action here
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(donorName.split('').join(' '), style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 5),
                  Text('Number: $donorNumber', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Email: $donorEmail', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Address: $donorAddress', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Tag: $donorTag', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
