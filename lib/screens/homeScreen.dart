import 'package:chefadmin/screens/AdminMenuUploadScreen.dart';
import 'package:chefadmin/screens/DayScholarOrdersScreen.dart';
import 'package:chefadmin/screens/Skip%20_StatsScreen.dart';
import 'package:chefadmin/screens/studetns_feesbackscreen.dart';
import 'package:chefadmin/screens/payment_history_screen.dart';
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
    // Determine screen width for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;

    // Web: 3 columns | Tablet: 2 columns | Mobile: 1 column
    int crossAxisCount = screenWidth > 1000 ? 3 : (screenWidth > 600 ? 2 : 1);
    double spacing = screenWidth > 600 ? 25 : 15;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      appBar: AppBar(
        title: Text(
          "Admin Control Center",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xffFFC800),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ), // Centers content on large web monitors
          padding: EdgeInsets.all(spacing),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: screenWidth > 600
                ? 1.4
                : 2.5, // Wider cards on web, taller on mobile
            shrinkWrap: true,
            children: [
              _buildMenuCard(
                title: 'Token Dashboard',
                subtitle: 'Real-time meal tracking',
                icon: Icons.dashboard_customize_rounded,
                color: Colors.teal,
                onTap: () => Get.to(() => TokenStatusScreen()),
              ),
              _buildMenuCard(
                title: 'User Management',
                subtitle: 'Approve & Renew access',
                icon: Icons.manage_accounts_rounded,
                color: Colors.indigo,
                onTap: () => Get.to(() => UpdateingUserStatusScreen()),
              ),
              _buildMenuCard(
                title: 'Token Logs',
                subtitle: 'Full generation history',
                icon: Icons.history_edu_rounded,
                color: Colors.blueGrey,
                onTap: () => Get.to(() => const TokenHistoryScreen()),
              ),
              _buildMenuCard(
                title: 'Revenue Records',
                subtitle: 'Online & Offline payments',
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.green.shade700,
                onTap: () => Get.to(() => const GlobalPaymentHistoryScreen()),
              ),
              _buildMenuCard(
                title: 'Menu Upload',
                subtitle: 'Food waste reduction stats',
                icon: Icons.no_meals_rounded,
                color: Colors.redAccent,
                onTap: () => Get.to(() => const AdminMenuUploadScreen()),
              ),
              _buildMenuCard(
                title: 'Day Scholar Orders',
                subtitle: 'Manage day scholar orders',
                icon: Icons.set_meal_sharp,
                color: const Color.fromARGB(255, 71, 252, 0),
                onTap: () => Get.to(() => DayScholarOrdersScreen()),
              ),
              // --- ✨ NEW CARD: Student Feedback ---
              _buildMenuCard(
                title: 'Student Feedback',
                subtitle: 'View ratings and student reviews',
                icon: Icons.feedback_rounded,
                color: Colors.amber.shade800,
                onTap: () => Get.to(() => const StudentsFeedbackScreen()),
              ),
              // --- ✨ NEW CARD: Meal Skipped Report ---
              _buildMenuCard(
                title: 'Meal Skipped Report',
                subtitle: 'Track skipped meals and counts',
                icon: Icons.event_busy_rounded,
                color: Colors.deepOrangeAccent,
                onTap: () => Get.to(() => const AdminMealReportScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
