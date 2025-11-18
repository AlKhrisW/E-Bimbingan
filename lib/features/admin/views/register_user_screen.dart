// lib/features/admin/views/register_user_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nimNipController = TextEditingController(); 
  final _placementController = TextEditingController();
  final _prodiController = TextEditingController();
  
  // State Dinamis
  String _selectedRole = 'Mahasiswa'; 
  UserModel? _selectedDosen;
  List<UserModel> _dosenList = [];
  bool _isDosenListLoading = true;
  DateTime? _startDate; 
  String? _selectedJabatan;

  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];
  final List<String> _jabatanOptions = ['Asisten Ahli', 'Lektor', 'Lektor Kepala', 'Guru Besar'];

  // FIX: Variabel untuk menampung Future
  late Future<void> _fetchDosenFuture;
  bool _isFutureInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FIX UTAMA: Pindahkan inisialisasi Future ke sini untuk memastikan context sudah siap
    if (!_isFutureInitialized) {
      _fetchDosenFuture = _fetchDosenList();
      _isFutureInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nimNipController.dispose();
    _placementController.dispose();
    _prodiController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchDosenList() async {
    // FIX: Provider.of sekarang dijamin bekerja di didChangeDependencies/setelah build
    final viewModel = Provider.of<AdminViewModel>(context, listen: false); 
    try {
      final list = await viewModel.fetchDosenList();
      setState(() {
        _dosenList = list.where((u) => u.role == 'dosen').toList();
        if (_dosenList.isNotEmpty) {
           _selectedDosen = _dosenList.first; 
        }
        _isDosenListLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat daftar Dosen: $e')));
      setState(() => _isDosenListLoading = false);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2026, 12));
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }
  
  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Mahasiswa' && _selectedDosen == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosen Pembimbing wajib dipilih.')));
        return;
    }
    if (_selectedRole == 'Mahasiswa' && _startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal Mulai Magang wajib diisi.')));
        return;
    }
    if (_selectedRole == 'Dosen' && _selectedJabatan == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jabatan Dosen wajib dipilih.')));
        return;
    }

    final viewModel = Provider.of<AdminViewModel>(context, listen: false);

    final success = await viewModel.registerUserUniversal(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole.toLowerCase(),
      programStudi: _prodiController.text.trim(),
      phoneNumber: _phoneController.text.trim(),

      // Mahasiswa fields
      placement: _selectedRole == 'Mahasiswa' ? _placementController.text.trim() : null,
      startDate: _selectedRole == 'Mahasiswa' ? _startDate : null,
      dosenUid: _selectedRole == 'Mahasiswa' ? _selectedDosen!.uid : null,

      // Dosen fields
      nip: _selectedRole == 'Dosen' ? _nimNipController.text.trim() : null,
      jabatan: _selectedRole == 'Dosen' ? _selectedJabatan : null,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil didaftarkan!')));
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  // --- HELPER WIDGETS DINAMIS ---
  Widget _buildRoleSpecificFields() {
    if (_selectedRole == 'Mahasiswa') {
      return Column(
        children: [
          _buildTextField(_nimNipController, 'NIM', Icons.badge, type: TextInputType.number),
          _buildTextField(_placementController, 'Penempatan Magang', Icons.business),
          _buildDateTile(),
          // FIX: Wrap dropdown Dosen dalam FutureBuilder untuk menunggu data
          FutureBuilder(
            future: _fetchDosenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              }
              return _buildDosenDropdown();
            }
          ),
        ],
      );
    } else if (_selectedRole == 'Dosen') {
      return Column(
        children: [
          _buildTextField(_nimNipController, 'NIP', Icons.badge, type: TextInputType.number),
          _buildJabatanDropdown(),
        ],
      );
    }
    return const SizedBox.shrink(); 
  }
  
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: type,
        validator: (value) => (value == null || value.isEmpty) ? '$label wajib diisi.' : null,
      ),
    );
  }

  Widget _buildDosenDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<UserModel>(
        decoration: const InputDecoration(labelText: 'Dosen Pembimbing', prefixIcon: Icon(Icons.people)),
        value: _selectedDosen,
        items: _dosenList.map((dosen) {
          return DropdownMenuItem(value: dosen, child: Text(dosen.name));
        }).toList(),
        onChanged: (UserModel? newValue) {
          setState(() { _selectedDosen = newValue; });
        },
        validator: (value) => value == null ? 'Dosen Pembimbing wajib dipilih.' : null,
      ),
    );
  }
  
  Widget _buildJabatanDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Jabatan Fungsional', prefixIcon: Icon(Icons.work)),
        value: _selectedJabatan,
        items: _jabatanOptions.map((jabatan) {
          return DropdownMenuItem(value: jabatan, child: Text(jabatan));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() { _selectedJabatan = newValue; });
        },
        validator: (value) => value == null ? 'Jabatan wajib dipilih.' : null,
      ),
    );
  }

  Widget _buildDateTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
        title: Text('Tanggal Mulai Magang: ${_startDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy').format(_startDate!)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectStartDate(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of sekarang aman karena dipanggil setelah didChangeDependencies
    final viewModel = Provider.of<AdminViewModel>(context); 
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah User', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FIELD UMUM ---
              _buildTextField(_nameController, 'Nama Lengkap', Icons.person),
              
              // --- FIELD ROLE DINAMIS ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.assignment_ind)),
                  value: _selectedRole,
                  items: _roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() { 
                      _selectedRole = newValue!; 
                      _nimNipController.clear(); 
                      _selectedJabatan = null;
                      _startDate = null;
                      _placementController.clear();
                    });
                  },
                ),
              ),
              
              _buildTextField(_prodiController, 'Program Studi/Jurusan', Icons.school),
              _buildTextField(_emailController, 'E-Mail', Icons.email, type: TextInputType.emailAddress),
              _buildTextField(_phoneController, 'No - Telp', Icons.phone, type: TextInputType.phone),

              // --- FIELD PASSWORD DEFAULT ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  initialValue: 'password', 
                  decoration: const InputDecoration(labelText: 'Password Default', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  readOnly: true, 
                ),
              ),
              
              // --- FIELD SPESIFIK ROLE (DINAMIS) ---
              const SizedBox(height: 24),
              _buildRoleSpecificFields(),
              
              const SizedBox(height: 40),

              // --- TOMBOL TAMBAH USER ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitRegistration,
                  child: viewModel.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tambah User', style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
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