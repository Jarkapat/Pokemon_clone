import 'package:flutter/material.dart';
import 'pages/car_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const CarListPage(),
    );
  }
}
