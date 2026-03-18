import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFC98E),
        title: const Text(
          'My First App',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: const Color(0xFFBDE3F4),
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1546842931-886c185b4c8c?auto=format&fit=crop&q=80&w=400',
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[400],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Container(
                color: const Color(0xFFE59DB4),
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'What image is that',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                color: const Color(0xFFFEF2A6),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconOption(Icons.restaurant, 'Food'),
                    _buildIconOption(Icons.landscape, 'Scenery'),
                    _buildIconOption(Icons.people, 'People'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                color: const Color(0xFFBCE6EC),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Counter here: $_counter',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    InkWell(
                      onTap: _incrementCounter,
                      child: Container(
                        color: const Color(0xFF9CE0EA),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.add, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    );
  }
}