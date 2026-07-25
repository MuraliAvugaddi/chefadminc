import 'package:chefadmin/controllers/updateing_user_status_controller.dart';
import 'package:chefadmin/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateingUserStatusScreen extends StatelessWidget {
  UpdateingUserStatusScreen({super.key});
  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F7FE), // Softer background color
        appBar: AppBar(
          toolbarHeight: 80,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Student Directory",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              Text(
                "Manage mess access and monthly renewals",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          actions: [
            _buildHeaderAction(
              icon: Icons.power_settings_new,
              color: Colors.red,
              onTap: () => controller.showDeactivateAllDialog(context),
              tooltip: "Reset Month",
            ),
            const SizedBox(width: 10),
            _buildHeaderAction(
              icon: Icons.refresh,
              color: const Color(0xffFFC800),
              onTap: () => controller.fetchUsers(),
              tooltip: "Sync Data",
            ),
            const SizedBox(width: 20),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xffFFC800),
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(child: _tabLabel("Active Students", Icons.verified_user)),
                  Tab(child: _tabLabel("Expired/Pending", Icons.error_outline)),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ), // Perfect for Web
            child: Column(
              children: [
                // --- 🔍 CUSTOM DASHBOARD SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: "Search by phone, name, or enrollment...",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xffFFC800),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 📋 GRID CONTENT ---
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildResponsiveGrid(context, controller, true),
                      _buildResponsiveGrid(context, controller, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    AdminController controller,
    bool showActive,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xffFFC800)),
        );
      }

      final users = showActive
          ? controller.activeUsers
          : controller.expiredUsers;

      if (users.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "No results found in this category",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1100
              ? 3
              : (MediaQuery.of(context).size.width > 700 ? 2 : 1),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 280,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) =>
            UserStatusCard(user: users[index], controller: controller),
      );
    });
  }
}

// --- 💳 MODERN DASHBOARD CARD ---
class UserStatusCard extends StatefulWidget {
  final AppUser user;
  final AdminController controller;
  const UserStatusCard({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  State<UserStatusCard> createState() => _UserStatusCardState();
}

class _UserStatusCardState extends State<UserStatusCard> {
  bool isHovered = false; // For Web Hover Effect

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isHovered
            ? (Matrix4.identity()..translate(0, -5, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFC800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      widget.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Obx(() {
                        bool isActive = widget.user.isApproved.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? "ACTIVE" : "EXPIRED",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(
              Icons.badge_outlined,
              "Enrollment",
              widget.user.enrollmentNo,
            ),
            _infoRow(
              Icons.phone_android_outlined,
              "Contact",
              widget.user.phonenumber,
            ),
            _infoRow(
              Icons.room_outlined,
              "Location",
              "Room ${widget.user.room}",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                bool isActive = widget.user.isApproved.value;
                return ElevatedButton(
                  onPressed: () =>
                      widget.controller.toggleApproval(widget.user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isActive ? "REVOKE ACCESS" : "RENEW ACCESS",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
