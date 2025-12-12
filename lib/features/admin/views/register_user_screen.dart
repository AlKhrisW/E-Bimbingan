// lib/features/admin/screens/register_user_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  final _startDateTextController = TextEditingController();
  final _endDateTextController = TextEditingController();
  // state dinamis
  String _selectedRole = 'Mahasiswa';
  UserModel? _selectedDosen;
  List<UserModel> _dosenList = [];
  bool _isDosenListLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedJabatan;
  String? _selectedProdi;
  bool _isEditMode = false;
  final List<String> _roles = ['Mahasiswa', 'Dosen', 'Admin'];
  final List<String> _prodiOptions = [
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
    _endDateTextController.dispose();
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
        }
        _endDate = user.endDate;
        if (_endDate != null) {
          _endDateTextController.text = DateFormat(
            'dd MMMM yyyy',
          ).format(_endDate!);
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
      // Untuk edit mode: jika dosenUid null atau kosong, set selectedDosen null
      if (_isEditMode &&
          (widget.userToEdit!.dosenUid == null ||
              widget.userToEdit!.dosenUid!.isEmpty)) {
        _selectedDosen = null;
      } else if (_isEditMode && widget.userToEdit!.dosenUid != null) {
        _selectedDosen = _dosenList.firstWhere(
          (d) => d.uid == widget.userToEdit!.dosenUid,
          orElse: () =>
              _dosenList.isNotEmpty ? _dosenList.first : null as UserModel,
        );
      } else if (_dosenList.isNotEmpty) {
        // Default: Belum Ada (akan ditangani di dropdown, selectedDosen null)
        _selectedDosen = null;
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

    // HAPUS validasi wajib dosen:
    // if (_selectedRole == 'Mahasiswa' && _selectedDosen == null) return;
    // Sekarang opsional

    if (_selectedRole == 'Mahasiswa' && _startDate == null) return;
    if (_selectedRole == 'Mahasiswa' && _endDate == null) return;
    if (_selectedRole == 'Dosen' && _selectedJabatan == null) return;
    if (_selectedRole == 'Mahasiswa' && _selectedProdi == null) return;

    final viewModel = Provider.of<AdminUserManagementViewModel>(
      context,
      listen: false,
    );

    // Tentukan dosenUid: jika selectedDosen null atau uid kosong, kirim null
    String? finalDosenUid;
    if (_selectedDosen != null && _selectedDosen!.uid.isNotEmpty) {
      finalDosenUid = _selectedDosen!.uid;
    } else {
      finalDosenUid = null;
    }

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
      'endDate': _selectedRole == 'Mahasiswa' ? _endDate : null,
      'dosenUid': _selectedRole == 'Mahasiswa' ? finalDosenUid : null,
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
        endDate: data['endDate'] as DateTime?,
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
        endDate: data['endDate'] as DateTime?,
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
        centerTitle: true,
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
              // 1. Nama Lengkap
              AdminTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              // 2. NIM / NIP
              if (_selectedRole == 'Mahasiswa')
                AdminTextField(
                  controller: _nimNipController,
                  label: 'NIM',
                  icon: Icons.badge,
                  type: TextInputType.number,
                  enabled: true,
                )
              else if (_selectedRole == 'Dosen')
                AdminTextField(
                  controller: _nimNipController,
                  label: 'NIP',
                  icon: Icons.badge,
                  type: TextInputType.number,
                  enabled: true,
                ),
              if (_selectedRole == 'Mahasiswa' || _selectedRole == 'Dosen')
                const SizedBox(height: 16),
              // 3. Role (label di atas)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _roles.contains(_selectedRole)
                        ? _selectedRole
                        : null,
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
                              _selectedProdi = null;
                              _selectedJabatan = null;
                              _startDate = null;
                              _endDate = null;
                              _startDateTextController.clear();
                              _endDateTextController.clear();
                              _selectedDosen = _dosenList.isNotEmpty
                                  ? _dosenList.first
                                  : null;
                            });
                          },
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Pilih role',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      prefixIcon: const Icon(
                        Icons.assignment_ind,
                        color: Colors.black87,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 4. Program Studi (label di atas)
              if (_selectedRole == 'Mahasiswa')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Program Studi/Jurusan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedProdi,
                      items: _prodiOptions
                          .map(
                            (prodi) => DropdownMenuItem(
                              value: prodi,
                              child: Text(prodi),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedProdi = val),
                      validator: (value) =>
                          value == null ? 'Program Studi wajib dipilih.' : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Pilih program studi',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                        prefixIcon: const Icon(
                          Icons.school,
                          color: Colors.black87,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selectedRole == 'Mahasiswa') const SizedBox(height: 16),
              // 5. Email
              AdminTextField(
                controller: _emailController,
                label: 'E-Mail',
                icon: Icons.email,
                type: TextInputType.emailAddress,
                enabled: true,
              ),
              const SizedBox(height: 16),
              // 6. No Telp
              AdminTextField(
                controller: _phoneController,
                label: 'No - Telp',
                icon: Icons.phone,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // 7. Password Default (hanya saat tambah baru)
              if (!_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password Default',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: 'password',
                        readOnly: true,
                        enabled: false,
                        obscureText: true,
                        onTap: () {},
                        style: TextStyle(color: Colors.grey.shade600),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black87,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              // === SECTION INFORMASI MAGANG ===
              if (_selectedRole == 'Mahasiswa') ...[
                Text(
                  'Informasi Magang',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                RegisterRoleFields(
                  selectedRole: _selectedRole,
                  isEditMode: _isEditMode,
                  isDosenListLoading: _isDosenListLoading,
                  nimNipController: _nimNipController,
                  placementController: _placementController,
                  startDateTextController: _startDateTextController,
                  endDateTextController: _endDateTextController,
                  startDate: _startDate,
                  endDate: _endDate,
                  selectedDosen: _selectedDosen,
                  dosenList: _dosenList,
                  onDateSelected: (d) => setState(() {
                    _startDate = d;
                    if (d != null) {
                      _startDateTextController.text = DateFormat(
                        'dd MMMM yyyy',
                      ).format(d);
                    } else {
                      _startDateTextController.clear();
                    }
                  }),
                  onEndDateSelected: (e) => setState(() {
                    _endDate = e;
                    if (e != null) {
                      _endDateTextController.text = DateFormat(
                        'dd MMMM yyyy',
                      ).format(e);
                    } else {
                      _endDateTextController.clear();
                    }
                  }),
                  onDosenChanged: (d) => setState(() => _selectedDosen = d),
                  jabatanOptions: _jabatanOptions,
                  selectedJabatan: _selectedJabatan,
                  onJabatanChanged: (j) => setState(() => _selectedJabatan = j),
                ),
              ],
              // Untuk Dosen: Jabatan
              if (_selectedRole == 'Dosen')
                RegisterRoleFields(
                  selectedRole: _selectedRole,
                  isEditMode: _isEditMode,
                  isDosenListLoading: _isDosenListLoading,
                  nimNipController: _nimNipController,
                  placementController: _placementController,
                  startDateTextController: _startDateTextController,
                  endDateTextController: _endDateTextController,
                  startDate: _startDate,
                  endDate: _endDate,
                  selectedDosen: _selectedDosen,
                  dosenList: _dosenList,
                  onDateSelected: (_) {},
                  onEndDateSelected: (_) {},
                  onDosenChanged: (_) {},
                  jabatanOptions: _jabatanOptions,
                  selectedJabatan: _selectedJabatan,
                  onJabatanChanged: (j) => setState(() => _selectedJabatan = j),
                ),
              const SizedBox(height: 40),
              // Tombol Submit
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
