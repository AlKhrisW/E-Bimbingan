import 'package:flutter/material.dart';
import 'package:ebimbingan/core/widgets/accordion/custom_accordion.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';

class UpdateDataDiri extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final Function(String name, String phone) onUpdate;

  const UpdateDataDiri({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.onUpdate,
  });

  @override
  State<UpdateDataDiri> createState() => _UpdateDataDiriState();
}

class _UpdateDataDiriState extends State<UpdateDataDiri> {
  final ExpansibleController _accordionController = ExpansibleController();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Memanggil fungsi update dari parent
        await widget.onUpdate(_nameController.text, _phoneController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data diri berhasil diperbarui!")),
          );
          // Opsi: Tutup keyboard
          FocusScope.of(context).unfocus();

          // Opsi: Tutup accordion setelah submit
          if (_accordionController.isExpanded) {
            _accordionController.collapse();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccordionWrapper(
      controller: _accordionController,
      title: "Update Data Diri",
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}