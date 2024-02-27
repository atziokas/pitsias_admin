import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pitsias_admin/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text('Pitsias Admin'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DocumentCountButton(
                    collection: 'issues',
                    conditionField: 'isResolved',
                    conditionValue: true,
                    color: Colors.green,
                  ),
                  DocumentCountButton(
                    collection: 'issues',
                    conditionField: 'isResolved',
                    conditionValue: false,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StoreGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentCountButton extends StatelessWidget {
  final String collection;
  final String conditionField;
  final bool conditionValue;
  final Color color;

  DocumentCountButton({
    required this.collection,
    required this.conditionField,
    required this.conditionValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(collection)
          .where(conditionField, isEqualTo: conditionValue)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 120, // Adjust the width of the button
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final countText = snapshot.data!.docs.length.toString();
        final buttonText = conditionValue ? 'Resolved' : 'Unresolved';
        return SizedBox(
          width: 120, // Adjust the width of the button
          height: 80,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              primary: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  countText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$buttonText Issues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class StoreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
      child: Center( // Center the GridView
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('stores').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final stores = snapshot.data!.docs;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final storeAddress = stores[index]['storeAddress'];
                // final storeID = stores[index].data()
                return StoreCard(storeAddress: storeAddress);
              },
            );
          },
        ),
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final String storeAddress;

  StoreCard({required this.storeAddress});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3, // Adjust card width as needed
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                storeAddress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('issues')
                  .where('issueStore', isEqualTo: storeAddress)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final issueCount = snapshot.data!.docs.length;
                return Text(
                  'Number of Issues: $issueCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Change color if desired
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

