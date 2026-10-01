import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../apis/apis_localhost.dart';
import '../models/user_models.dart';
import '../controllers/updateing_user_status_controller.dart';

class ChefColors {
  static const primary = Color(0xFFFFC800);
  static const primaryDark = Color(0xFF9A7600);
  static const primarySoft = Color(0xFFFFF6CC);

  static const background = Color(0xFFF6F8FC);
  static const surface = Colors.white;
  static const border = Color(0xFFE5EAF2);

  static const text = Color(0xFF172033);
  static const muted = Color(0xFF667085);

  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFEAF8EF);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFFEEEE);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFF7E6);
}

class StudentFinancialScreen extends StatefulWidget {
  const StudentFinancialScreen({super.key});

  @override
  State<StudentFinancialScreen> createState() => _StudentFinancialScreenState();
}

class _StudentFinancialScreenState extends State<StudentFinancialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final AdminController adminController = Get.put(AdminController());

  String selectedGender = 'All';
  String selectedMonth = 'October 2026'; // Defaults directly to active month
  bool showUnpaidOnly = false;

  // Cached O(1) set of paid student IDs for the currently selected month
  final Set<String> _currentMonthPaidUserIds = {};
  
  // Storage for dialog UTRs: userId -> { monthName -> utr }
  final Map<String, Map<String, String>> _userPaymentMap = {};
  bool _isLoadingPayments = false;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Dynamically generated months list ensuring October is always included
  List<String> get monthsList {
    final now = DateTime.now();
    final cur = '${_monthNames[now.month - 1]} ${now.year}';
    return [
      'All Year',
      'August 2026',
      'September 2026',
      'October 2026',
      if (!cur.contains('August') && !cur.contains('September') && !cur.contains('October'))
        cur,
    ].toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final now = DateTime.now();
    selectedMonth = '${_monthNames[now.month - 1]} ${now.year}';

    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    adminController.fetchUsers();
    await _fetchGlobalPayments();
  }

  Future<void> _fetchGlobalPayments() async {
    try {
      setState(() => _isLoadingPayments = true);
      final response = await http.get(
        Uri.parse('${ApiEndpoints.adminAllPayments}?month=All Year'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List payments = (data is List) ? data : (data['payments'] ?? []);

        _userPaymentMap.clear();

        for (var p in payments) {
          final status = (p['status'] ?? '').toString().trim().toLowerCase();
          final amount = num.tryParse((p['amount'] ?? 0).toString()) ?? 0;
          final mName = (p['month'] ?? '').toString().trim();
          final txn = (p['transactionId'] ?? '').toString().trim();

          if ((status == 'success' || (txn.isNotEmpty && txn != 'N/A' && txn != 'n/a')) && amount > 0) {
            String uid = '';
            if (p['userId'] is Map) {
              uid = (p['userId']['_id'] ?? p['userId']['id'] ?? '').toString();
            } else {
              uid = (p['userId'] ?? '').toString();
            }

            if (uid.isNotEmpty) {
              _userPaymentMap.putIfAbsent(uid, () => {})[mName.toLowerCase()] = txn;
            }
          }
        }

        _recalculateCurrentMonthPaidSet();
      }
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPayments = false);
      }
    }
  }

  // Precomputes the Set in O(N) once so build runs in O(1) time
  void _recalculateCurrentMonthPaidSet() {
    _currentMonthPaidUserIds.clear();
    final target = selectedMonth.toLowerCase().trim();
    final isAllYear = (target == 'all year');
    final targetPrefix = target.split(' ')[0];

    _userPaymentMap.forEach((uid, monthMap) {
      if (isAllYear) {
        final hasAug = monthMap.keys.any((k) => k.contains('august'));
        final hasSep = monthMap.keys.any((k) => k.contains('september'));
        final hasOct = monthMap.keys.any((k) => k.contains('october'));
        if (hasAug && hasSep && hasOct) {
          _currentMonthPaidUserIds.add(uid);
        }
      } else {
        if (monthMap.keys.any((k) => k.contains(targetPrefix))) {
          _currentMonthPaidUserIds.add(uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: ChefColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ChefColors.primary,
          brightness: Brightness.light,
        ),
      ),
      child: Scaffold(
        backgroundColor: ChefColors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 850;

              return Column(
                children: [
                  _buildMetricsSummaryBar(isCompact),
                  _buildFilterToolbar(isCompact),
                  _buildTabs(isCompact),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStudentListView(isJunior: true, isCompact: isCompact),
                        _buildStudentListView(isJunior: false, isCompact: isCompact),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ChefColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (Get.key.currentState?.canPop() == true) {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 19),
        ),
      ),
      toolbarHeight: 62,
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: ChefColors.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.restaurant_rounded, color: ChefColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chef Hospitality',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: const Color(0xFF1A1A1A), fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Student finance & access',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: const Color(0xFF5F4B00), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sync Data',
          onPressed: () => _loadAllData(),
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildExcelExportButton(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ChefColors.border),
      ),
    );
  }

  Widget _buildTabs(bool isCompact) {
    return Container(
      margin: EdgeInsets.fromLTRB(isCompact ? 12 : 20, 3, isCompact ? 12 : 20, 5),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: const Color(0xFFEFF3F8), borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 38,
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: ChefColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 2))],
          ),
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: ChefColors.muted,
          labelStyle: GoogleFonts.poppins(fontSize: isCompact ? 11 : 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: isCompact ? 11 : 12, fontWeight: FontWeight.w500),
          tabs: const [Tab(text: 'Juniors · 1st Year'), Tab(text: 'Seniors · 2nd–5th Year')],
        ),
      ),
    );
  }

  Widget _buildMetricsSummaryBar(bool isCompact) {
    return Obx(() {
      final allUsers = adminController.filteredUsers;
      final totalCount = allUsers.length;

      // O(1) set membership check instead of inner loop
      final activeCount = allUsers.where((u) => _currentMonthPaidUserIds.contains(u.id)).length;
      final noAccessCount = totalCount - activeCount;

      return Padding(
        padding: EdgeInsets.fromLTRB(isCompact ? 12 : 20, 8, isCompact ? 12 : 20, 2),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Students',
                count: totalCount.toString(),
                icon: Icons.people_alt_outlined,
                iconBackground: ChefColors.primarySoft,
                iconColor: ChefColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Active Access',
                count: activeCount.toString(),
                icon: Icons.verified_outlined,
                iconBackground: ChefColors.successSoft,
                iconColor: ChefColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Needs Attention',
                count: noAccessCount.toString(),
                icon: Icons.warning_amber_rounded,
                iconBackground: ChefColors.warningSoft,
                iconColor: ChefColors.warning,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ChefColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(count, style: GoogleFonts.poppins(color: ChefColors.text, fontSize: 18, fontWeight: FontWeight.w800, height: 1.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(bool isCompact) {
    return Container(
      margin: EdgeInsets.fromLTRB(isCompact ? 12 : 20, 6, isCompact ? 12 : 20, 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: ChefColors.border)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: adminController.updateSearchQuery,
              style: GoogleFonts.poppins(fontSize: 13, color: ChefColors.text),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search name, phone or student ID',
                prefixIcon: Icon(Icons.search_rounded, color: ChefColors.primary),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: _buildFilterDropdown(
              value: selectedGender,
              icon: Icons.people_outline_rounded,
              items: const ['All', 'Male', 'Female'],
              onChanged: (val) {
                if (val != null) setState(() => selectedGender = val);
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 175,
            child: _buildFilterDropdown(
              value: selectedMonth,
              icon: Icons.calendar_month_outlined,
              items: monthsList,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedMonth = val;
                    _recalculateCurrentMonthPaidSet();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          _buildUnpaidFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : items.first;

    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String>(
        value: effectiveValue,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ChefColors.muted, size: 20),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFAFBFD),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          prefixIcon: Icon(icon, size: 17, color: ChefColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ChefColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ChefColors.border)),
        ),
        style: GoogleFonts.poppins(color: ChefColors.text, fontSize: 12, fontWeight: FontWeight.w600),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUnpaidFilter() {
    return FilterChip(
      selected: showUnpaidOnly,
      showCheckmark: false,
      avatar: Icon(
        showUnpaidOnly ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        size: 17,
        color: showUnpaidOnly ? const Color(0xFF8A6800) : ChefColors.muted,
      ),
      label: const Text('Unpaid only'),
      selectedColor: ChefColors.primarySoft,
      backgroundColor: const Color(0xFFFAFBFD),
      side: BorderSide(color: showUnpaidOnly ? ChefColors.primary : ChefColors.border),
      labelStyle: GoogleFonts.poppins(color: showUnpaidOnly ? const Color(0xFF6B5200) : ChefColors.text, fontSize: 12, fontWeight: FontWeight.w600),
      onSelected: (val) => setState(() => showUnpaidOnly = val),
    );
  }

  Widget _buildStudentListView({required bool isJunior, required bool isCompact}) {
    return Obx(() {
      if (adminController.isLoading.value || _isLoadingPayments) {
        return const Center(child: CircularProgressIndicator(color: ChefColors.primary, strokeWidth: 2.5));
      }

      final filtered = adminController.filteredUsers.where((u) {
        final matchesYear = isJunior ? (u.year == '1' || u.year.contains('1')) : (u.year != '1' && !u.year.contains('1'));
        final isPaid = _currentMonthPaidUserIds.contains(u.id);
        final matchesUnpaid = !showUnpaidOnly || !isPaid;
        final matchesGender = selectedGender == 'All' || u.gender.trim().toLowerCase() == selectedGender.trim().toLowerCase();
        return matchesYear && matchesUnpaid && matchesGender;
      }).toList();

      if (filtered.isEmpty) return _buildEmptyState();

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(isCompact ? 12 : 20, 4, isCompact ? 12 : 20, 20),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final student = filtered[index];
          final isPaid = _currentMonthPaidUserIds.contains(student.id);
          return _buildStudentCard(student, isPaid: isPaid, isCompact: isCompact);
        },
      );
    });
  }

  Widget _buildStudentCard(AppUser student, {required bool isPaid, required bool isCompact}) {
    final initial = student.name.trim().isNotEmpty ? student.name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ChefColors.border)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: isPaid ? ChefColors.primarySoft : const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(13)),
            alignment: Alignment.center,
            child: Text(initial, style: GoogleFonts.poppins(color: isPaid ? ChefColors.primaryDark : ChefColors.muted, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(student.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: ChefColors.text, fontSize: 14, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isPaid ? ChefColors.successSoft : ChefColors.dangerSoft, borderRadius: BorderRadius.circular(20)),
                      child: Text(isPaid ? 'PAID' : 'UNPAID', style: GoogleFonts.poppins(color: isPaid ? ChefColors.success : ChefColors.danger, fontSize: 8.5, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  children: [
                    Text(student.enrollmentNo, style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 10.5)),
                    Text('Room ${student.room}', style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 10.5)),
                    Text(student.gender, style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 10.5)),
                    Text('Father: ${student.fatherPhone.isEmpty ? '—' : student.fatherPhone}', style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => _showManualPaymentDialog(student),
            icon: const Icon(Icons.payments_outlined, size: 17),
            label: const Text('Record payment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ChefColors.primaryDark,
              side: const BorderSide(color: ChefColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => adminController.toggleApproval(student),
            style: TextButton.styleFrom(foregroundColor: isPaid ? ChefColors.danger : ChefColors.success),
            child: Text(isPaid ? 'Revoke access' : 'Grant access'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: ChefColors.primary, size: 38),
            const SizedBox(height: 10),
            Text('No students found', style: GoogleFonts.poppins(color: ChefColors.text, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualPaymentDialog(AppUser student) async {
    final amountController = TextEditingController(text: '4000');
    final fatherPhoneController = TextEditingController(text: student.fatherPhone);
    final dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    final utrController = TextEditingController();

    // Default to the current active calendar month automatically
    final now = DateTime.now();
    final realMonth = '${_monthNames[now.month - 1]} ${now.year}';
    String selectedMonthInDialog = realMonth;

    final dialogMonthsList = [
      'August 2026',
      'September 2026',
      'October 2026',
      if (!realMonth.contains('August') && !realMonth.contains('September') && !realMonth.contains('October'))
        realMonth,
    ].toSet().toList();

    final userPaidSet = _userPaymentMap[student.id] ?? {};

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(color: ChefColors.primarySoft, shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long_rounded, color: ChefColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Record / Edit payment', style: GoogleFonts.poppins(color: ChefColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                              Text(student.name, style: GoogleFonts.poppins(color: ChefColors.muted, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => Navigator.of(dialogContext).pop(), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Select Month', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),

                    // Renders all month cards with Green PAID vs Red PENDING
                    ...dialogMonthsList.map((mName) {
                      final prefix = mName.split(' ')[0].toLowerCase();
                      final isPaid = userPaidSet.keys.any((k) => k.contains(prefix));
                      final isSelected = (selectedMonthInDialog == mName);

                      return _buildMonthSelectRow(
                        monthName: mName,
                        isSelected: isSelected,
                        isPaid: isPaid,
                        onTap: () {
                          setDialogState(() {
                            selectedMonthInDialog = mName;
                            utrController.text = userPaidSet[prefix] ?? '';
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount per month (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: utrController,
                      decoration: InputDecoration(labelText: 'UTR / Receipt ID for $selectedMonthInDialog *', prefixIcon: const Icon(Icons.confirmation_number_outlined)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: fatherPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Father's Phone Number", prefixIcon: Icon(Icons.family_restroom_outlined)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Payment date (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today_outlined)),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (utrController.text.trim().isEmpty) {
                            Get.snackbar('UTR required', 'Enter UTR number', backgroundColor: ChefColors.danger, colorText: Colors.white);
                            return;
                          }

                          final parsedAmount = num.tryParse(amountController.text.trim()) ?? 4000;

                          try {
                            final res = await http.post(
                              Uri.parse(ApiEndpoints.adminManualPayment),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'userId': student.id,
                                'amount': parsedAmount,
                                'paymentsData': [{'month': selectedMonthInDialog, 'transactionId': utrController.text.trim()}],
                                'fatherPhone': fatherPhoneController.text.trim(),
                                'paymentDate': dateController.text.trim(),
                              }),
                            );

                            if (res.statusCode == 200) {
                              Navigator.of(dialogContext).pop();
                              _loadAllData();
                              Get.snackbar('Saved', 'Payment for $selectedMonthInDialog saved.', backgroundColor: ChefColors.success, colorText: Colors.white);
                            }
                          } catch (e) {
                            Get.snackbar('Error', 'Server connection error.', backgroundColor: ChefColors.danger, colorText: Colors.white);
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text('Save $selectedMonthInDialog payment & approve', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(backgroundColor: ChefColors.primary, foregroundColor: Colors.white, elevation: 0),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelectRow({
    required String monthName,
    required bool isSelected,
    required bool isPaid,
    required VoidCallback onTap,
  }) {
    Color bgColor = isSelected ? const Color(0xFFFFF9E6) : (isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2));
    Color borderColor = isSelected ? const Color(0xFFF59E0B) : (isPaid ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(11), border: Border.all(color: borderColor, width: 1.4)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                border: Border.all(color: isSelected ? const Color(0xFFF59E0B) : (isPaid ? const Color(0xFF22C55E) : const Color(0xFFEF4444)), width: 1.8),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(monthName, style: GoogleFonts.poppins(color: ChefColors.text, fontSize: 13, fontWeight: FontWeight.w600))),
            if (isSelected)
              Text('SELECTED', style: GoogleFonts.poppins(color: const Color(0xFFB45309), fontSize: 10.5, fontWeight: FontWeight.w800))
            else if (isPaid)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)), child: Text('PAID', style: GoogleFonts.poppins(color: const Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w800)))
            else
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)), child: Text('PENDING', style: GoogleFonts.poppins(color: const Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }

  Widget _buildExcelExportButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        final group = _tabController.index == 0 ? 'Junior' : 'Senior';
        final urlString = '${ApiEndpoints.adminExportExcel}?yearGroup=$group&gender=$selectedGender&month=$selectedMonth&unpaidOnly=$showUnpaidOnly';

        final response = await http.get(Uri.parse(urlString));
        if (response.statusCode == 200) {
          final blob = html.Blob([response.bodyBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)..setAttribute('download', 'Chef_Hospitality_$selectedMonth.xlsx')..click();
          html.Url.revokeObjectUrl(url);
        }
      },
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: Text(showUnpaidOnly ? 'Export Unpaid Excel' : 'Export Excel', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFF1A1A1A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}