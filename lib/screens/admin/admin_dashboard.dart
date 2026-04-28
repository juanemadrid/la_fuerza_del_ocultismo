import 'package:flutter/material.dart';
import 'manage_horoscopes.dart';
import 'manage_users.dart';
import 'manage_pdfs.dart';
import 'manage_config.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PANEL DE CONTROL'),
        backgroundColor: const Color(0xFF0D0D0D),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFF1A0000),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAdminCard(
                context,
                'HORÓSCOPO',
                Icons.star_outline,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageHoroscopes())),
              ),
              _buildAdminCard(
                context,
                'CLIENTES',
                Icons.people_outline,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsers())),
              ),
              _buildAdminCard(
                context,
                'CONTENIDO PDF',
                Icons.picture_as_pdf_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePDFs())),
              ),
              _buildAdminCard(
                context,
                'CONFIGURACIÓN',
                Icons.settings_outlined,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageConfig())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB71C1C), width: 2),
          color: Colors.black.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFB71C1C), size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
