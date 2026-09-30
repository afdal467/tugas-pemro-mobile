import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Profil Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nama = 'Belum diisi';
  String _npm = 'Belum diisi';
  String _jurusan = 'Belum diisi';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadData(); // Memuat data tersimpan saat aplikasi dibuka
  }

  // Fungsi untuk mengambil data yang sudah disimpan sebelumnya
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? 'Belum diisi';
      _npm = prefs.getString('npm') ?? 'Belum diisi';
      _jurusan = prefs.getString('jurusan') ?? 'Belum diisi';
      _imagePath = prefs.getString('imagePath');
    });
  }

  // Fungsi untuk membuka form input/edit
  void _openInputForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InputFormSheet(
        currentNama: _nama == 'Belum diisi' ? '' : _nama,
        currentNpm: _npm == 'Belum diisi' ? '' : _npm,
        currentJurusan: _jurusan == 'Belum diisi' ? '' : _jurusan,
        currentImagePath: _imagePath,
        onSaved: (nama, npm, jurusan, imagePath) {
          setState(() {
            _nama = nama;
            _npm = npm;
            _jurusan = jurusan;
            _imagePath = imagePath;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _openInputForm,
            tooltip: 'Input / Ubah Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Tampilan Foto Profil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _imagePath != null && File(_imagePath!).existsSync()
                        ? FileImage(File(_imagePath!))
                        : null,
                child: (_imagePath == null || !File(_imagePath!).existsSync())
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 30),
            // Card Data Mahasiswa
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text('Nama Lengkap',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_nama,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.badge, color: Colors.blue),
                      title: const Text('NPM',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_npm,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.school, color: Colors.blue),
                      title: const Text('Jurusan',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_jurusan,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Tombol untuk membuka form input data
            ElevatedButton.icon(
              onPressed: _openInputForm,
              icon: const Icon(Icons.edit),
              label: const Text('INPUT / UBAH DATA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget Form Input (Popup ke bawah / BottomSheet)
class InputFormSheet extends StatefulWidget {
  final String currentNama;
  final String currentNpm;
  final String currentJurusan;
  final String? currentImagePath;
  final Function(String, String, String, String?) onSaved;

  const InputFormSheet({
    super.key,
    required this.currentNama,
    required this.currentNpm,
    required this.currentJurusan,
    this.currentImagePath,
    required this.onSaved,
  });

  @override
  State<InputFormSheet> createState() => _InputFormSheetState();
}

class _InputFormSheetState extends State<InputFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _npmController;
  late TextEditingController _jurusanController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.currentNama);
    _npmController = TextEditingController(text: widget.currentNpm);
    _jurusanController = TextEditingController(text: widget.currentJurusan);
    _imagePath = widget.currentImagePath;
  }

  // Fungsi memilih foto dari galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  // Fungsi Tombol Save (Menyimpan data ke SharedPreferences)
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama', _namaController.text);
      await prefs.setString('npm', _npmController.text);
      await prefs.setString('jurusan', _jurusanController.text);
      if (_imagePath != null) {
        await prefs.setString('imagePath', _imagePath!);
      }

      // Kirim kembali data ke halaman utama
      widget.onSaved(
        _namaController.text,
        _npmController.text,
        _jurusanController.text,
        _imagePath,
      );

      // Tutup form
      Navigator.pop(context);

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _npmController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Form Biodata Mahasiswa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Bagian Foto Profile dengan tombol kamera
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _imagePath != null && File(_imagePath!).existsSync()
                              ? FileImage(File(_imagePath!))
                              : null,
                      child: (_imagePath == null ||
                              !File(_imagePath!).existsSync())
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Input Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              // Input NPM
              TextFormField(
                controller: _npmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NPM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'NPM wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              // Input Jurusan
              TextFormField(
                controller: _jurusanController,
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Jurusan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),
              // Tombol Save
              ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save),
                label: const Text('SIMPAN DATA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
