import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebimbingan/core/widgets/custom_universal_back_appBar.dart';
import 'package:ebimbingan/features/dosen/viewmodels/dosen_logbook_harian_viewmodel.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_header.dart';
import 'package:ebimbingan/features/dosen/widgets/logbook_harian/logbook_list.dart';

class DosenLogbookHarian extends StatefulWidget {
  final String mahasiswaUid;

  const DosenLogbookHarian({
    super.key,
    required this.mahasiswaUid,
  });

  @override
  State<DosenLogbookHarian> createState() => _DosenLogbookHarianState();
}

class _DosenLogbookHarianState extends State<DosenLogbookHarian> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DosenLogbookHarianViewModel>()
          .pilihMahasiswa(widget.mahasiswaUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(
        judul: "Logbook Harian Mahasiswa",
      ),
      body: Consumer<DosenLogbookHarianViewModel>(
        builder: (context, vm, child) {
          final m = vm.selectedMahasiswa;

          return Column(
            children: [
              if (m != null)
                LogbookHeader(
                  name: m.name,
                  nim: m.nim ?? "-",
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              const SizedBox(height: 8),
              Expanded(child: LogbookList(mahasiswaUid: widget.mahasiswaUid)),
            ],
          );
        },
      ),
    );
  }
}
