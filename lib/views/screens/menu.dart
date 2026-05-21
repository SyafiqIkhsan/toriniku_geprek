import 'package:flutter/material.dart';
import 'TambahMenuPage';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> daftarMenu = [
      {
        'nama': 'Ayam Geprek',
        'kategori': 'Makanan',
        'harga': 'Rp 18.000',
        'tersedia': true,
      },
      {
        'nama': 'Es Teh Manis',
        'kategori': 'Minuman',
        'harga': 'Rp 5.000',
        'tersedia': false,
      },
      {
        'nama': 'Jeruk Peras (Es/Hangat)',
        'kategori': 'Minuman',
        'harga': 'Rp 7.000',
        'tersedia': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: Color(0xffff6600),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          // Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title dengan Tombol Tambah Menu
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Menu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Total: 4 Produk aktif',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TambahMenuPage()),
                          );
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.white, size: 36),
                      ),
                    ],
                  ),
                ),

                // List Menu Item
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: daftarMenu.length,
                    itemBuilder: (context, index) {
                      final menu = daftarMenu[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon placeholder pengganti gambar makanan
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xffff6600).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                menu['kategori'] == 'Makanan' 
                                    ? Icons.restaurant 
                                    : Icons.local_drink,
                                color: const Color(0xffff6600),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Informasi Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu['nama'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: menu['tersedia'] ? Colors.black : Colors.grey,
                                      decoration: menu['tersedia'] 
                                          ? TextDecoration.none 
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    menu['harga'],
                                    style: const TextStyle(
                                      color: Color(0xffff6600),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Switch / Status Ketersediaan
                            Text(
                              menu['tersedia'] ? 'Ready' : 'Habis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: menu['tersedia'] ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}