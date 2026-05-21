import 'package:flutter/material.dart';

class TambahPesananPage extends StatelessWidget {
  const TambahPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      body: Stack(
        children: [
          // Background Orange melengkung khas atas atas
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: Color(0xffff6600),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Kembali & Judul
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      const Text(
                        'Pesanan Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Input Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pesanan Pelanggan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Nama Pelanggan
                          _buildTextField(
                            label: 'Nama Pelanggan / Nomor Meja',
                            hint: 'Contoh: Meja 05 atau Andi',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // Input Detail Menu Pesanan
                          _buildTextField(
                            label: 'Menu yang Dipesan',
                            hint: 'Contoh: 2x Ayam Geprek S2, 1x Es Teh',
                            icon: Icons.restaurant_menu,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Input Catatan Khusus
                          _buildTextField(
                            label: 'Catatan Tambahan',
                            hint: 'Contoh: Sambal dipisah, es teh manis',
                            icon: Icons.note_alt_outlined,
                          ),
                          const SizedBox(height: 32),

                          // Tombol Simpan Pesanan
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                // Logika simpan data nanti dimasukkan di sini
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pesanan berhasil ditambahkan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffff6600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Simpan & Proses Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper untuk membuat input text field yang estetik
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xffff6600)),
            filled: true,
            fillColor: const Color(0xfff9f9f9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffe3e3e3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffff6600), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}