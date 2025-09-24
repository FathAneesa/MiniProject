// test_flutter_connection.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestConnectionPage());
  }
}

class TestConnectionPage extends StatefulWidget {
  @override
  _TestConnectionPageState createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _result = 'Not tested yet';

  Future<void> testConnection() async {
    setState(() {
      _result = 'Testing connection...';
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8081/students');
      final response = await http.get(url).timeout(Duration(seconds: 10));

      setState(() {
        _result = 'Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connection Test')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: testConnection,
              child: Text('Test Connection'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
