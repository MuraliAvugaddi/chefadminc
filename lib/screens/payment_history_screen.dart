import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_history_controller.dart';

class GlobalPaymentHistoryScreen extends StatelessWidget {
  const GlobalPaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentHistoryController());
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        title: Text(
          "Revenue Records",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xffFFC800),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Filter Bar & Summary Section
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildFilterBar(context, controller, isWideScreen),
                    _buildSummaryCard(controller),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content (Loading, Empty, or List)
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xffFFC800)),
                ),
              );
            }

            if (controller.payments.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No records found for this selection",
                        style: GoogleFonts.poppins(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? (screenWidth - 1000) / 2 : 16,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final payment = controller.payments[index];
                  final user = payment['userId'] ?? {};
                  final bool isOffline = payment['method'] == 'offline';
                  final DateTime paidAt = DateTime.parse(
                    payment['paidAt'],
                  ).toLocal();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Method Icon Indicator
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isOffline
                                  ? Colors.green[50]
                                  : Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isOffline
                                  ? Icons.payments_outlined
                                  : Icons.account_balance_wallet_outlined,
                              color: isOffline ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Detailed Student & Transaction Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user['name'] ?? "Unknown Student",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOffline
                                            ? Colors.green.shade100
                                            : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isOffline ? "CASH" : "CASHFREE ONLINE",
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isOffline
                                              ? Colors.green.shade800
                                              : Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Student Academic Meta details
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  children: [
                                    _metaDetail(
                                      Icons.badge_outlined,
                                      "ID: ${user['enrollmentNo'] ?? 'N/A'}",
                                    ),
                                    _metaDetail(
                                      Icons.school_outlined,
                                      "Year: ${user['year'] ?? 'N/A'}",
                                    ),
                                    _metaDetail(
                                      Icons.meeting_room_outlined,
                                      "Room: ${user['room'] ?? 'N/A'}",
                                    ),
                                    _metaDetail(
                                      Icons.phone_outlined,
                                      "${user['phonenumber'] ?? 'N/A'}",
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),

                                // Transaction & Timestamp info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Txn ID: ${payment['transactionId'] ?? 'Manual Cash Entry'}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy, hh:mm a',
                                          ).format(paidAt),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₹${payment['amount']}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: controller.payments.length),
              ),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Small helper widget for crisp metadata alignment
  Widget _metaDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(PaymentHistoryController controller) {
    return Obx(() {
      double total = controller.payments.fold(
        0,
        (sum, item) => sum + (item['amount'] ?? 0),
      );
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black, Color(0xff2D2D2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Collection",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFC800).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xffFFC800),
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterBar(
    BuildContext context,
    PaymentHistoryController controller,
    bool isWide,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Gender Filter
          Expanded(
            child: _filterTile(
              label: "Gender",
              value: controller.selectedGender,
              icon: Icons.person_search_outlined,
              onTap: () => _showPicker(
                context,
                "Select Gender",
                ["All", "Male", "Female"],
                (val) => controller.updateFilters(gender: val),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Calendar Date Picker Button
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
              ),
              icon: const Icon(
                Icons.calendar_month,
                size: 16,
                color: Color(0xffFFC800),
              ),
              label: Obx(
                () => Text(
                  controller.selectedDate.value == null
                      ? "Filter Date"
                      : DateFormat(
                          'dd MMM',
                        ).format(controller.selectedDate.value!),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate.value ?? DateTime.now(),
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  controller.updateFilters(date: pickedDate);
                }
              },
            ),
          ),
          // Clear Date filter button if active
          Obx(
            () => controller.selectedDate.value != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                    onPressed: () => controller.updateFilters(clearDate: true),
                    tooltip: "Clear Date Filter",
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _filterTile({
    required String label,
    required RxString value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xffFFC800)),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(
                () => Text(
                  value.value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPicker(
    BuildContext context,
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map(
              (option) => ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(option, style: GoogleFonts.poppins()),
                onTap: () {
                  onSelect(option);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
