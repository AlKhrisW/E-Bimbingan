// lib/features/admin/views/register_user_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_viewmodel.dart';

class RegisterUserScreen extends StatefulWidget {
  final UserModel? userToEdit;
  const RegisterUserScreen({super.key, this.userToEdit});

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
  bool _isEditMode = false; // Flag mode Edit

  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];
  final List<String> _jabatanOptions = [
    'Asisten Ahli',
    'Lektor',
    'Lektor Kepala',
    'Guru Besar',
  ];

  late Future<void> _fetchDosenFuture;
  bool _isFutureInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFutureInitialized) {
      _isEditMode = widget.userToEdit != null;
      _initializeFields();
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

  void _initializeFields() {
    final user = widget.userToEdit;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _prodiController.text = user.programStudi ?? '';
      // FIX: Set role dengan kapitalisasi yang benar
      _selectedRole =
          user.role.substring(0, 1).toUpperCase() + user.role.substring(1);

      if (user.role == 'mahasiswa') {
        _nimNipController.text = user.nim ?? '';
        _placementController.text = user.placement ?? '';
        _startDate = user.startDate;
      } else if (user.role == 'dosen') {
        _nimNipController.text = user.nip ?? '';
        _selectedJabatan = user.jabatan;
      }
    }
  }

  Future<void> _fetchDosenList() async {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);
    try {
      final list = await viewModel.fetchDosenList();
      if (!mounted) return;

      setState(() {
        _dosenList = list.where((u) => u.role == 'dosen').toList();

        // FIX UNTUK EDIT MODE: Set Dosen yang sudah ada
        if (_isEditMode && widget.userToEdit!.dosenUid != null) {
          _selectedDosen = _dosenList.firstWhere(
            (d) => d.uid == widget.userToEdit!.dosenUid,
            orElse: () => _dosenList.first,
          );
        } else if (_dosenList.isNotEmpty) {
          _selectedDosen = _dosenList.first;
        }
        _isDosenListLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat daftar Dosen: $e')));
      setState(() => _isDosenListLoading = false);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2026, 12),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Mahasiswa' && _selectedDosen == null) return;
    if (_selectedRole == 'Mahasiswa' && _startDate == null) return;
    if (_selectedRole == 'Dosen' && _selectedJabatan == null) return;

    final viewModel = Provider.of<AdminViewModel>(context, listen: false);

    // Kumpulan Data Universal
    final data = {
      'email': _emailController.text.trim(),
      'name': _nameController.text.trim(),
      'role': _selectedRole.toLowerCase(),
      'programStudi': _prodiController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),

      // mahasiswa
      'nim': _selectedRole == 'Mahasiswa'
          ? _nimNipController.text.trim()
          : null,
      'placement': _selectedRole == 'Mahasiswa'
          ? _placementController.text.trim()
          : null,
      'startDate': _selectedRole == 'Mahasiswa' ? _startDate : null,
      'dosenUid': _selectedRole == 'Mahasiswa' ? _selectedDosen?.uid : null,

      // dosen
      'nip': _selectedRole == 'Dosen' ? _nimNipController.text.trim() : null,
      'jabatan': _selectedRole == 'Dosen' ? _selectedJabatan : null,
    };

    bool success;
    if (_isEditMode) {
      success = await viewModel.updateUserData(
        UserModel(
          uid: widget.userToEdit!.uid,
          email: data['email'] as String,
          name: data['name'] as String,
          role: data['role'] as String,
          programStudi: data['programStudi'] as String,
          phoneNumber: data['phoneNumber'] as String,
          placement: data['placement'] as String?,
          startDate: data['startDate'] as DateTime?,
          dosenUid: data['dosenUid'] as String?,
          nip: data['nip'] as String?,
          jabatan: data['jabatan'] as String?,
        ),
      );
    } else {
      success = await viewModel.registerUserUniversal(
        email: data['email'] as String,
        name: data['name'] as String,
        role: data['role'] as String,
        programStudi: data['programStudi'] as String,
        phoneNumber: data['phoneNumber'] as String,
        nim: data['nim'] as String?, 
        placement: data['placement'] as String?,
        startDate: data['startDate'] as DateTime?,
        dosenUid: data['dosenUid'] as String?,
        nip: data['nip'] as String?,
        jabatan: data['jabatan'] as String?,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Data berhasil diupdate!'
                : 'User berhasil didaftarkan!',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  // --- HELPER WIDGETS DINAMIS ---
  Widget _buildRoleSpecificFields() {
    final bool isNimNipEnabled = !_isEditMode;

    if (_selectedRole == 'Mahasiswa') {
      return Column(
        children: [
          _buildTextField(
            _nimNipController,
            'NIM',
            Icons.badge,
            type: TextInputType.number,
            enabled: isNimNipEnabled,
          ), // NIM bisa diubah (HANYA CREATE)
          _buildTextField(
            _placementController,
            'Penempatan Magang',
            Icons.business,
            enabled: true,
          ), // Penempatan bisa diubah
          _buildDateTile(),
          _isDosenListLoading
              ? const Center(child: LinearProgressIndicator())
              : _buildDosenDropdown(),
        ],
      );
    } else if (_selectedRole == 'Dosen') {
      return Column(
        children: [
          _buildTextField(
            _nimNipController,
            'NIP',
            Icons.badge,
            type: TextInputType.number,
            enabled: isNimNipEnabled,
          ), // NIP bisa diubah (HANYA CREATE)
          _buildJabatanDropdown(), // Dropdown Jabatan selalu bisa diubah
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: type,
        // Validator hanya dijalankan jika field enabled
        validator: enabled
            ? (value) => (value == null || value.isEmpty)
                  ? '$label wajib diisi.'
                  : null
            : null,
      ),
    );
  }

  Widget _buildDosenDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<UserModel>(
        decoration: const InputDecoration(
          labelText: 'Dosen Pembimbing',
          prefixIcon: Icon(Icons.people),
        ),
        value: _selectedDosen,
        items: _dosenList.map((dosen) {
          return DropdownMenuItem(value: dosen, child: Text(dosen.name));
        }).toList(),
        onChanged: (UserModel? newValue) {
          setState(() {
            _selectedDosen = newValue;
          });
        },
        validator: (value) =>
            value == null ? 'Dosen Pembimbing wajib dipilih.' : null,
      ),
    );
  }

  Widget _buildJabatanDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Jabatan Fungsional',
          prefixIcon: Icon(Icons.work),
        ),
        value: _selectedJabatan,
        items: _jabatanOptions.map((jabatan) {
          return DropdownMenuItem(value: jabatan, child: Text(jabatan));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedJabatan = newValue;
          });
        },
        validator: (value) => value == null ? 'Jabatan wajib dipilih.' : null,
      ),
    );
  }

  Widget _buildDateTile() {
    // Tanggal Mulai Magang hanya relevan dan bisa diubah jika Mahasiswa
    final isEnabled = _selectedRole == 'Mahasiswa';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.calendar_month,
          color: isEnabled ? AppTheme.primaryColor : Colors.grey,
        ),
        title: Text(
          'Tanggal Mulai Magang: ${_startDate == null ? "Pilih Tanggal" : DateFormat('dd MMMM yyyy').format(_startDate!)}',
          style: TextStyle(
            color: isEnabled ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isEnabled ? Colors.black87 : Colors.grey,
        ),
        onTap: isEnabled ? () => _selectStartDate(context) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    // Pastikan _selectedRole yang disetel dari _initializeFields saat mode EDIT tidak menimbulkan error.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userToEdit == null
              ? 'Tambah User'
              : 'Edit User: ${widget.userToEdit?.name}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              _buildTextField(
                _nameController,
                'Nama Lengkap',
                Icons.person,
                enabled: true,
              ), // Nama diaktifkan untuk edit
              // --- FIELD ROLE DINAMIS ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.assignment_ind),
                  ),
                  value: _roles.contains(_selectedRole) ? _selectedRole : null,
                  items: _roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  // FIX: Menghilangkan duplikasi parameter onChanged
                  onChanged: _isEditMode
                      ? null
                      : (String? newValue) {
                          // Role tidak bisa diubah saat edit
                          setState(() {
                            _selectedRole = newValue!;
                            _nimNipController.clear();
                            _selectedJabatan = null;
                            _startDate = null;
                            _placementController.clear();
                          });
                        },
                  isDense: true,
                  isExpanded: true,
                  hint: !_isEditMode
                      ? null
                      : Text(
                          _selectedRole,
                          style: TextStyle(color: Colors.black),
                        ),
                  style: !_isEditMode ? null : TextStyle(color: Colors.black87),
                ),
              ),

              _buildTextField(
                _prodiController,
                'Program Studi/Jurusan',
                Icons.school,
                enabled: true,
              ), // Program Studi bisa diubah
              _buildTextField(
                _emailController,
                'E-Mail',
                Icons.email,
                type: TextInputType.emailAddress,
                enabled: !_isEditMode, // <-- Tambah user = true, Edit = false
              ),

              _buildTextField(
                _phoneController,
                'No - Telp',
                Icons.phone,
                type: TextInputType.phone,
                enabled: true,
              ), // Nomor telepon bisa diubah
              // --- FIELD PASSWORD DEFAULT ---
              if (!_isEditMode) // Hanya tampilkan password saat Tambah User
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    initialValue: 'password',
                    decoration: const InputDecoration(
                      labelText: 'Password Default',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    readOnly: true,
                  ),
                ),

              // --- FIELD SPESIFIK ROLE (DINAMIS) ---
              const SizedBox(height: 24),
              _buildRoleSpecificFields(),

              const SizedBox(height: 40),

              // --- TOMBOL TAMBAH/UPDATE USER ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitRegistration,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? 'Update Data User' : 'Tambah User',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
