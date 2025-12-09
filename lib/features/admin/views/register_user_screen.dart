import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import untuk DateFormat

import '../../../../data/models/user_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/custom_button_back.dart';
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

  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nimNipController = TextEditingController();
  final _placementController = TextEditingController();
  final _startDateTextController =
      TextEditingController(); // Controller teks tanggal

  // state dinamis
  String _selectedRole = 'Mahasiswa';
  UserModel? _selectedDosen;
  List<UserModel> _dosenList = [];
  bool _isDosenListLoading = true;
  DateTime? _startDate;
  String? _selectedJabatan;
  String? _selectedProdi; // State untuk Prodi yang dipilih
  bool _isEditMode = false;

  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];
  final List<String> _prodiOptions = [
    // Daftar Program Studi
    'Sistem Informasi Bisnis',
    'Teknik Informatika',
  ];
  final List<String> _jabatanOptions = [
    'Asisten Ahli',
    'Lektor',
    'Lektor Kepala',
    'Guru Besar',
  ];

  bool _isFutureInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFutureInitialized) {
      _isEditMode = widget.userToEdit != null;
      _initializeFields();
      Future.microtask(() {
        if (mounted) _fetchDosenList();
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
    _startDateTextController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    final user = widget.userToEdit;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _selectedRole =
          user.role.substring(0, 1).toUpperCase() + user.role.substring(1);

      if (user.role == 'mahasiswa') {
        _selectedProdi = user.programStudi;
        _nimNipController.text = user.nim ?? '';
        _placementController.text = user.placement ?? '';
        _startDate = user.startDate;
        if (_startDate != null) {
          _startDateTextController.text = DateFormat(
            'dd MMMM yyyy',
          ).format(_startDate!);
        } else {
          _startDateTextController.clear();
        }
      } else if (user.role == 'dosen') {
        _nimNipController.text = user.nip ?? '';
        _selectedJabatan = user.jabatan;
      }
    }
  }

  Future<void> _fetchDosenList() async {
    final viewModel = Provider.of<AdminUserManagementViewModel>(
      context,
      listen: false,
    );
    await viewModel.loadDosenList();

    if (!mounted) return;

    setState(() {
      _dosenList = viewModel.users;
      if (_isEditMode && widget.userToEdit!.dosenUid != null) {
        _selectedDosen = _dosenList.firstWhere(
          (d) => d.uid == widget.userToEdit!.dosenUid,
          orElse: () =>
              _dosenList.isNotEmpty ? _dosenList.first : null as UserModel,
        );
      } else if (_dosenList.isNotEmpty) {
        _selectedDosen = _dosenList.first;
      }
      if (_dosenList.isEmpty) _selectedDosen = null;
      _isDosenListLoading = false;
    });

    if (viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat daftar dosen: ${viewModel.errorMessage!}',
          ),
        ),
      );
      viewModel.resetMessages();
    }
  }

  String? _safeTrim(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Mahasiswa' && _selectedDosen == null) return;
    if (_selectedRole == 'Mahasiswa' && _startDate == null) return;
    if (_selectedRole == 'Dosen' && _selectedJabatan == null) return;
    if (_selectedRole == 'Mahasiswa' && _selectedProdi == null)
      return; // Validasi Prodi

    final viewModel = Provider.of<AdminUserManagementViewModel>(
      context,
      listen: false,
    );

    final data = {
      'email': _safeTrim(_emailController.text)!,
      'name': _safeTrim(_nameController.text)!,
      'role': _selectedRole.toLowerCase(),
      'programStudi': _selectedRole == 'Mahasiswa' ? _selectedProdi : null,
      'phoneNumber': _safeTrim(_phoneController.text),
      'nim': _selectedRole == 'Mahasiswa'
          ? _safeTrim(_nimNipController.text)
          : null,
      'placement': _selectedRole == 'Mahasiswa'
          ? _safeTrim(_placementController.text)
          : null,
      'startDate': _selectedRole == 'Mahasiswa' ? _startDate : null,
      'dosenUid': _selectedRole == 'Mahasiswa' ? _selectedDosen?.uid : null,
      'nip': _selectedRole == 'Dosen'
          ? _safeTrim(_nimNipController.text)
          : null,
      'jabatan': _selectedRole == 'Dosen' ? _selectedJabatan : null,
    };

    bool success;
    if (_isEditMode) {
      success = await viewModel.updateUserUniversal(
        uid: widget.userToEdit!.uid,
        email: data['email'] as String,
        name: data['name'] as String,
        role: data['role'] as String,
        programStudi: data['programStudi'] as String?,
        phoneNumber: data['phoneNumber'] as String,
        nim: data['nim'] as String?,
        placement: data['placement'] as String?,
        startDate: data['startDate'] as DateTime?,
        dosenUid: data['dosenUid'] as String?,
        nip: data['nip'] as String?,
        jabatan: data['jabatan'] as String?,
      );
    } else {
      success = await viewModel.registerUserUniversal(
        email: data['email'] as String,
        name: data['name'] as String,
        role: data['role'] as String,
        programStudi: data['programStudi'] as String?,
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
          content: Text(viewModel.successMessage ?? 'Operasi berhasil!'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Operasi gagal.')),
      );
    }
    viewModel.resetMessages();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminUserManagementViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        centerTitle: true, // Judul di tengah
        title: Text(
          widget.userToEdit == null ? 'Tambah Pengguna Baru' : 'Edit Pengguna',
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
              AdminTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
              ),

              // role dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.assignment_ind),
                  ),
                  value: _roles.contains(_selectedRole) ? _selectedRole : null,
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: _isEditMode
                      ? null
                      : (val) {
                          setState(() {
                            _selectedRole = val!;
                            _nimNipController.clear();
                            _placementController.clear();
                            _selectedProdi = null; // reset prodi
                            _selectedJabatan = null;
                            _startDate = null;
                            _startDateTextController
                                .clear(); // clear text tanggal
                            _selectedDosen = _dosenList.isNotEmpty
                                ? _dosenList.first
                                : null;
                          });
                        },
                  isExpanded: true,
                ),
              ),

              if (_selectedRole == 'Mahasiswa')
                // Menggunakan Dropdown untuk Program Studi
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Program Studi/Jurusan',
                      prefixIcon: Icon(Icons.school),
                    ),
                    value: _selectedProdi,
                    items: _prodiOptions.map((prodi) {
                      return DropdownMenuItem(value: prodi, child: Text(prodi));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProdi = val;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Program Studi wajib dipilih.' : null,
                    isExpanded: true,
                  ),
                ),

              AdminTextField(
                controller: _emailController,
                label: 'E-Mail',
                icon: Icons.email,
                type: TextInputType.emailAddress,
                enabled: true, // Selalu enable
              ),

              AdminTextField(
                controller: _phoneController,
                label: 'No - Telp',
                icon: Icons.phone,
                type: TextInputType.phone,
              ),

              // password default - benar-benar disabled
              if (!_isEditMode)
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
                    enabled: false, // kunci utama
                    onTap: () {}, // cegah fokus
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),

              const SizedBox(height: 24),

              RegisterRoleFields(
                selectedRole: _selectedRole,
                isEditMode: _isEditMode,
                isDosenListLoading: _isDosenListLoading,
                nimNipController: _nimNipController,
                placementController: _placementController,
                startDate: _startDate,
                startDateTextController:
                    _startDateTextController, // Meneruskan Controller
                selectedDosen: _selectedDosen,
                dosenList: _dosenList,
                jabatanOptions: _jabatanOptions,
                selectedJabatan: _selectedJabatan,
                onDateSelected: (d) => setState(() {
                  _startDate = d;
                  // Update text controller saat tanggal dipilih
                  _startDateTextController.text = d != null
                      ? DateFormat('dd MMMM yyyy').format(d)
                      : '';
                }),
                onDosenChanged: (d) => setState(() => _selectedDosen = d),
                onJabatanChanged: (j) => setState(() => _selectedJabatan = j),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitRegistration,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditMode ? 'Update Data User' : 'Tambah User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
