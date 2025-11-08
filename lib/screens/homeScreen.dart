import 'package:chefadmin/screens/token_history_screen.dart';
import 'package:chefadmin/screens/token_status_scrren.dart';
import 'package:chefadmin/screens/updateing_user_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Admin Panel", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xffFFC800),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuButton(
              context: context,
              title: 'Token Dashboard',
              icon: Icons.confirmation_number,
              onTap: () {
                Get.to(() => TokenStatusScreen());
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context: context,
              title: 'User Management',
              icon: Icons.people_alt,
              onTap: () {
                Get.to(() => UpdateingUserStatusScreen());
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context: context,
              title: 'History of Tokens',
              icon: Icons.people_alt,
              onTap: () {
                Get.to(() => TokenHistoryScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        elevation: 4,
      ),
    );
  }
}
