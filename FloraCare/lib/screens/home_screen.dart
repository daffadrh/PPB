import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/plant.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import 'add_plant_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _refreshPlants();
  }

  void _refreshPlants() async {
    final data = await DatabaseHelper.instance.queryAllPlants();
    setState(() {
      _plants = data;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _waterNow(Plant plant) async {
    // 1. Munculkan notifikasi konfirmasi langsung
    await NotificationService.triggerInstantWateringNotification(plant.name);

    // 2. Jalankan/Reset ulang timer notifikasi untuk hari berikutnya
    await NotificationService.scheduleWateringReminder(plant.id!, plant.name, plant.waterFrequencyDays);

    // 3. Tampilkan pesan di layar
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💧 Timer untuk ${plant.name} direset ke ${plant.waterFrequencyDays} hari!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background lebih bersih
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text('Koleksi Tanaman', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
        ],
      ),
      body: _plants.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: Colors.teal[200]),
            const SizedBox(height: 16),
            const Text('Belum ada tanaman.\nYuk tambahkan sekarang!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          final plant = _plants[index];
          return Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Foto Tanaman
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: plant.imagePath.startsWith('http')
                        ? Image.network(plant.imagePath, width: 85, height: 85, fit: BoxFit.cover)
                        : Image.file(File(plant.imagePath), width: 85, height: 85, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  // Detail Tanaman
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text(plant.species, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Siram tiap ${plant.waterFrequencyDays} hari', style: TextStyle(fontSize: 12, color: Colors.teal[700], fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Aksi
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.water_drop, color: Colors.blue),
                        tooltip: 'Siram Sekarang?',
                        onPressed: () => _waterNow(plant),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Hapus',
                        onPressed: () async {
                          // Hapus notifikasi timer saat tanaman dihapus
                          await NotificationService.cancelNotification(plant.id!);
                          await DatabaseHelper.instance.delete(plant.id!);
                          _refreshPlants();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tanaman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlantScreen()));
          _refreshPlants();
        },
      ),
    );
  }
}