import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
final sampleDataFutureProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await http.get(Uri.parse('http://localhost/saff-assignment/api/get_contacts.php'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data;
  } else {
    throw Exception('Failed to fetch sample data');
  }
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Riverpod Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Contacts Data')),
        body: 
        Consumer(
          builder: (context, watch, child) {
            final sampleDataFuture = ref.watch(sampleDataFutureProvider);
            return sampleDataFuture.when(
              data: (contactsData) => SampleTable(data: contactsData),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text('Error: $error'),
            );
          },
        ),
      ),
    );
  }
}

class SampleTable extends StatelessWidget {
  final List<dynamic> data;

  SampleTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Phone')),
      ],
      rows: data
          .map(
            (item) => DataRow(
          cells: <DataCell>[
            DataCell(Text(item['name'])),
            DataCell(Text(item['email'])),
            DataCell(Text(item['phone'].toString())),
          ],
        ),
      )
          .toList(),
    );
  }
}