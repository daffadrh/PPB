import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/plant.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({Key? key}) : super(key: key);

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _frequencyController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePlant() async {
    if (_image == null || _nameController.text.isEmpty || _frequencyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi foto dan data tanaman!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.teal)),
      );

      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text,
        'species': _speciesController.text,
        'waterFrequencyDays': int.parse(_frequencyController.text),
        'imagePath': _image!.path,
      });

      Plant newPlant = Plant(
        name: _nameController.text,
        species: _speciesController.text,
        waterFrequencyDays: int.parse(_frequencyController.text),
        imagePath: _image!.path,
      );
      int id = await DatabaseHelper.instance.insert(newPlant);

      // Jadwalkan notifikasi berulang pertama kalinya
      await NotificationService.scheduleWateringReminder(
          id, newPlant.name, newPlant.waterFrequencyDays);

      Navigator.pop(context);
      Navigator.pop(context);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tanaman: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Tanaman', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _getImage(ImageSource.gallery),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.teal.shade200, width: 2, style: BorderStyle.solid),
                ),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.teal[400]),
                    const SizedBox(height: 12),
                    Text('Ketuk untuk pilih foto galeri', style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.teal),
                label: const Text('Gunakan Kamera', style: TextStyle(color: Colors.teal))
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Nama Tanaman', Icons.local_florist_outlined),
            const SizedBox(height: 16),
            _buildTextField(_speciesController, 'Spesies', Icons.eco_outlined),
            const SizedBox(height: 16),
            _buildTextField(_frequencyController, 'Frekuensi Siram (Hari)', Icons.water_drop_outlined, isNumber: true),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _savePlant,
              child: const Text('Simpan Tanaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.teal[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}