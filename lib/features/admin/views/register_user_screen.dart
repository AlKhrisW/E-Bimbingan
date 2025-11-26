// lib/features/admin/views/register_user_screen.dart (Final Version)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../viewmodels/admin_user_management_viewmodel.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/register_user_widgets/register_user_widgets.dart';


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
  bool _isEditMode = false;

  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];
  final List<String> _jabatanOptions = [
    'Asisten Ahli', 'Lektor', 'Lektor Kepala', 'Guru Besar',
  ];

  bool _isFutureInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFutureInitialized) {
      _isEditMode = widget.userToEdit != null;
      _initializeFields();

      Future.microtask(() {
          if (mounted) {
              _fetchDosenList(); 
              // setState di sini tidak perlu karena _fetchDosenList akan memanggilnya
          }
      });
      
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
      _selectedRole = user.role.substring(0, 1).toUpperCase() + user.role.substring(1);

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
    final viewModel = Provider.of<AdminUserManagementViewModel>(context, listen: false); 
    
    await viewModel.loadDosenList(); 
    
    if (!mounted) return;

    final list = viewModel.users; 
    
    setState(() {
      _dosenList = list;
      if (_isEditMode && widget.userToEdit!.dosenUid != null) {
        _selectedDosen = _dosenList.firstWhere(
          (d) => d.uid == widget.userToEdit!.dosenUid,
          orElse: () => _dosenList.isNotEmpty ? _dosenList.first : null as UserModel, 
        );
      } else if (_dosenList.isNotEmpty) {
        _selectedDosen = _dosenList.first; 
      }
      if (_dosenList.isEmpty) _selectedDosen = null;
      _isDosenListLoading = false;
    });
    
    if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar Dosen: ${viewModel.errorMessage!}')),
      );
      viewModel.resetMessages(); 
    }
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Mahasiswa' && _selectedDosen == null) return;
    if (_selectedRole == 'Mahasiswa' && _startDate == null) return;
    if (_selectedRole == 'Dosen' && _selectedJabatan == null) return;

    final viewModel = Provider.of<AdminUserManagementViewModel>(context, listen: false);

    // Kumpulan Data Universal (Data tetap di sini karena ini adalah Logic Layer)
    final data = {
      'email': _emailController.text.trim(),
      'name': _nameController.text.trim(),
      'role': _selectedRole.toLowerCase(),
      'programStudi': _prodiController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'nim': _selectedRole == 'Mahasiswa' ? _nimNipController.text.trim() : null,
      'placement': _selectedRole == 'Mahasiswa' ? _placementController.text.trim() : null,
      'startDate': _selectedRole == 'Mahasiswa' ? _startDate : null,
      'dosenUid': _selectedRole == 'Mahasiswa' ? _selectedDosen?.uid : null,
      'nip': _selectedRole == 'Dosen' ? _nimNipController.text.trim() : null,
      'jabatan': _selectedRole == 'Dosen' ? _selectedJabatan : null,
    };

    bool success;
    if (_isEditMode) {
      // Panggil UPDATE
      success = await viewModel.updateUserUniversal(
        uid: widget.userToEdit!.uid,
        email: data['email'] as String,
        name: data['name'] as String,
        role: data['role'] as String,
        programStudi: data['programStudi'] as String,
        phoneNumber: data['phoneNumber'] as String,
        nim: data['nim'] as String?, placement: data['placement'] as String?,
        startDate: data['startDate'] as DateTime?, dosenUid: data['dosenUid'] as String?,
        nip: data['nip'] as String?, jabatan: data['jabatan'] as String?,
      );
    } else {
      // Panggil REGISTER
      success = await viewModel.registerUserUniversal(
        email: data['email'] as String,
        name: data['name'] as String,
        role: data['role'] as String,
        programStudi: data['programStudi'] as String,
        phoneNumber: data['phoneNumber'] as String,
        nim: data['nim'] as String?, placement: data['placement'] as String?,
        startDate: data['startDate'] as DateTime?, dosenUid: data['dosenUid'] as String?,
        nip: data['nip'] as String?, jabatan: data['jabatan'] as String?,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.successMessage ?? 'Operasi berhasil!')),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Operasi gagal, coba lagi.')),
      );
    }
    viewModel.resetMessages(); 
  }

  // NOTE: Semua _build helper method telah dihapus dan diganti dengan widget
  
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminUserManagementViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userToEdit == null ? 'Tambah User' : 'Edit User: ${widget.userToEdit?.name}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              // --- FIELD UMUM MENGGUNAKAN WIDGET BARU ---
              AdminTextField(controller: _nameController, label: 'Nama Lengkap', icon: Icons.person),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.assignment_ind)),
                  value: _roles.contains(_selectedRole) ? _selectedRole : null,
                  items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: _isEditMode
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                            _nimNipController.clear();
                            _selectedJabatan = null;
                            _startDate = null;
                            _placementController.clear();
                            _selectedDosen = _dosenList.isNotEmpty ? _dosenList.first : null;
                          });
                        },
                  isDense: true,
                  isExpanded: true,
                  hint: !_isEditMode ? null : Text(_selectedRole, style: const TextStyle(color: Colors.black)),
                  style: !_isEditMode ? null : const TextStyle(color: Colors.black87),
                ),
              ),

              AdminTextField(controller: _prodiController, label: 'Program Studi/Jurusan', icon: Icons.school),
              AdminTextField(
                controller: _emailController,
                label: 'E-Mail',
                icon: Icons.email,
                type: TextInputType.emailAddress,
                enabled: !_isEditMode,
              ),

              AdminTextField(
                controller: _phoneController,
                label: 'No - Telp',
                icon: Icons.phone,
                type: TextInputType.phone,
              ),

              // --- FIELD PASSWORD DEFAULT ---
              if (!_isEditMode) 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    initialValue: 'password',
                    decoration: const InputDecoration(labelText: 'Password Default', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    readOnly: true,
                  ),
                ),

              // --- FIELD SPESIFIK ROLE (MENGGUNAKAN WIDGET BARU) ---
              const SizedBox(height: 24),
              RegisterRoleFields(
                selectedRole: _selectedRole,
                isEditMode: _isEditMode,
                isDosenListLoading: _isDosenListLoading,
                nimNipController: _nimNipController,
                placementController: _placementController,
                startDate: _startDate,
                selectedDosen: _selectedDosen,
                dosenList: _dosenList,
                jabatanOptions: _jabatanOptions,
                selectedJabatan: _selectedJabatan,
                // Passing Callbacks ke Widget Anak
                onDateSelected: (picked) {
                  if (picked != null) setState(() => _startDate = picked);
                },
                onDosenChanged: (dosen) => setState(() => _selectedDosen = dosen),
                onJabatanChanged: (jabatan) => setState(() => _selectedJabatan = jabatan),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL SUBMIT ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitRegistration, 
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? 'Update Data User' : 'Tambah User',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
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